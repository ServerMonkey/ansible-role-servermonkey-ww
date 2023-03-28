#!/bin/sh
#info: Show SMART errors for all kinds of disks, including RAID and Flash.
#arg: critical
#arginfo: Shows only critical errors, much less verbose
#autoroot
# shellcheck disable=SC2039

###### GLOBAL VARIABLES #######################################################

CRITICAL="$1"
PARAMETER="critical"

###### INIT ###################################################################

# windows
if [ -n "$(command -v systeminfo)" ]; then
    echo "Windows is not supported" >&2
    exit 1
fi

# must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

###### FUNCTIONS ##############################################################

smart_value() {
    # parameters
    local IN_SMART_DATA="$1"
    local SMART_ID="$2"

    # get the right SMART value, if there is none mark it N/A
    local SMART_VALUE
    if [ -z "${SMART_ID}" ]; then
        SMART_VALUE="N/A"
    else
        SMART_VALUE=$(echo "$IN_SMART_DATA" | jq -r \
            ".ata_smart_attributes.table[] | select( .id == $SMART_ID ).value")
    fi

    echo "$SMART_VALUE"
}

check_disk() {
    # parameters
    local DISK_PATH="$1"

    # check if smartctl is installed
    local HAS_SMART
    local HAS_VER7
    local HAS_JSON

    HAS_SMART=$(command -v smartctl)
    if [ -z "${HAS_SMART}" ]; then
        echo "Smartctl is not installed. Please install." >&2
        return 1
    # if smartctl is installed
    else
        # check for the right version
        HAS_VER7=$(smartctl --version | grep "release 7")
        if [ -z "${HAS_VER7}" ]; then
            if [ "$CRITICAL" = "$PARAMETER" ]; then
                :
            else
                echo "$DISK_PATH Warning:" \
                    "Smartctl version lower than 7 is not supportet." >&2
            fi
            return 0
        else
            # check also if jq is installed
            HAS_JSON=$(command -v jq)
            if [ -z "${HAS_JSON}" ]; then
                echo "jq is not installed. Please install." >&2
                return 1
            fi
        fi
    fi

    # find ATA drives behind SAT layer
    local SMART_DATA_TESTING
    local SMART_DATA
    SMART_DATA_TESTING=$(smartctl -a "$DISK_PATH")
    # get SMART data
    if echo "$SMART_DATA_TESTING" | grep -iq "SAT layer"; then
        SMART_DATA=$(smartctl -j -a -d ata "$DISK_PATH")
    else
        SMART_DATA=$(smartctl -j -a "$DISK_PATH")
    fi

    # Disk product and brand name
    local DISK_NAME
    DISK_NAME=$(echo "$SMART_DATA" | jq -r ".model_name")

    # test if the disk has smart attributes att all
    local HAS_SMART_ATT
    HAS_SMART_ATT=$(echo "$SMART_DATA" | jq -r ".ata_smart_attributes")
    # if the smart attributes are empty
    if [ "$HAS_SMART_ATT" = "null" ]; then
        # check if the disk is part of hardware raid
        local DISK_PATH_NAME
        local DISK_VENDOR
        local DISK_MODEL
        DISK_PATH_NAME=$(basename "$DISK_PATH")
        DISK_VENDOR=$(tr -d ' ' <"/sys/block/$DISK_PATH_NAME/device/vendor")
        DISK_MODEL=$(tr -d ' ' <"/sys/block/$DISK_PATH_NAME/device/model")
        if [ ! "$CRITICAL" = "$PARAMETER" ]; then
            if echo "$DISK_MODEL" | grep -iq "iscsi"; then
                # ignore network attached iSCSI disks
                :
            else
                echo "$DISK_PATH is part of a RAID: $DISK_VENDOR $DISK_MODEL"
            fi
        fi
        return 0
    fi

    # select the current device
    local ID_REAL
    local ID_UNCO
    local ID_WEAR
    local ID_LIFE

    case $DISK_NAME in
    "KINGSTON SHFS37A4"*)
        ID_UNCO=187
        ID_LIFE=231
        ;;
    "INTEL SSDSC2BB"*)
        ID_REAL=5
        ID_UNCO=187
        ;;
    "Samsung SSD 840 EVO 250GB")
        ID_REAL=5
        ID_UNCO=187
        ID_WEAR=177
        echo "$DISK_PATH Warning: Samsung SSD 840 has bad firmware." \
            "Please replace."
        ;;
    "Samsung SSD 8"?"0 EVO"*)
        ID_REAL=5
        ID_UNCO=187
        ID_WEAR=177
        ;;
    "Samsung SSD 8"?"0 PRO"*)
        ID_REAL=5
        ID_UNCO=187
        ID_WEAR=177
        ;;
    "Samsung SSD 8"?"0 QVO"*)
        ID_REAL=5
        ID_UNCO=187
        ID_WEAR=177
        ;;
    "WDC  WDS100T2B0A-"*)
        ID_REAL=5
        ID_UNCO=187
        ID_WEAR=169
        ;;
    "SAMSUNG MZ7KM480HAHP-"*)
        ID_REAL=5
        ID_UNCO=187
        ;;
    "ST2000DX002-"*)
        ID_REAL=5
        ID_UNCO=187
        ;;
    "ST2000NC000-"*)
        ID_REAL=5
        ID_UNCO=187
        ;;
    "ST4000NM0115-"*)
        ID_REAL=5
        ID_UNCO=187
        ;;
    "ST4000NM115-"*)
        ID_REAL=5
        ID_UNCO=187
        ;;
    "ST8000VN0022-"*)
        ID_REAL=5
        ID_UNCO=187
        ;;
    "WDC WUS721010AL"*)
        ID_REAL=5
        ID_UNCO=187
        ;;
    "TOSHIBA HDWG"*)
        ID_REAL=5
        ID_UNCO=198
        ;;
    "SMC LSI"*)
        echo "$DISK_PATH Ignoring Supermicro RAID disk"
        return 1
        ;;
    "LSI MR"*)
        echo "$DISK_PATH Ignoring MegaRaid disk"
        return 1
        ;;
    "SATA SSD")
        echo "$DISK_PATH Warning: Low quality SSD found. Please replace."
        return 1
        ;;
    "null")
        echo "$DISK_PATH Ignoring Type variable is null"
        return 1
        ;;
    "")
        echo "$DISK_PATH Ignoring Type variable is empty"
        return 1
        ;;
    *)
        echo "$DISK_PATH Warning: Unknown disk type '$DISK_NAME'." \
            "Please add this disk type to the script."
        return 1
        ;;
    esac

    # get data

    local SMART_REAL # How many reallocation errors
    SMART_REAL=$(smart_value "$SMART_DATA" "$ID_REAL")
    local SMART_UNCO # How many uncorrectable errors
    SMART_UNCO=$(smart_value "$SMART_DATA" "$ID_UNCO")
    local SMART_WEAR # Wear level count, how much hase beend written/read
    SMART_WEAR=$(smart_value "$SMART_DATA" "$ID_WEAR")
    local SMART_LIFE # Manufacturers disk life expectancy, is like SMART_WEAR
    SMART_LIFE=$(smart_value "$SMART_DATA" "$ID_LIFE")

    # the result of the last run smartctl test
    local LAST_TEST_STATUS
    LAST_TEST_STATUS=$(smartctl -j -a "$DISK_PATH" | jq -r \
        .ata_smart_self_test_log.standard.table[0].status.string)

    # critical attribute values
    local CRIT_REAL=99 # 100 is no errors, everything below 99 is critical.
    local CRIT_UNCO=99 # 100 is no errors, everything below 100 is critical.
    local CRIT_WEAR=30 # 100 is new, below 20 is too old and affects w speed.
    local CRIT_LIFE=50 # up to the manufacturer, let's guess below 50 is bad.

    # print only critical disks
    if [ "$CRITICAL" = "$PARAMETER" ]; then

        local RESULT
        local DO_ACTION="Please Replace."

        if [ "$SMART_REAL" != "N/A" ]; then
            if [ "$SMART_REAL" -le "$CRIT_REAL" ]; then
                RESULT=$((100 - SMART_REAL))
                echo "$DISK_PATH There is(are) $RESULT" \
                    "reallocation error(s) on $DISK_NAME." \
                    "$DO_ACTION"
            fi
        fi

        if [ "$SMART_UNCO" != "N/A" ]; then
            if [ "$SMART_UNCO" -le "$CRIT_UNCO" ]; then
                RESULT=$((100 - SMART_UNCO))
                echo "$DISK_PATH There is(are) $RESULT" \
                    "uncorrectable error(s) on $DISK_NAME." \
                    "$DO_ACTION"
            fi
        fi

        if [ "$SMART_WEAR" != "N/A" ]; then
            if [ "$SMART_WEAR" -le "$CRIT_WEAR" ]; then
                echo "$DISK_PATH Only $SMART_WEAR" \
                    "percent of usage is left for $DISK_NAME." \
                    "$DO_ACTION"
            fi
        fi

        if [ "$SMART_LIFE" != "N/A" ]; then
            if [ "$SMART_LIFE" -le "$CRIT_LIFE" ]; then
                echo "$DISK_PATH Only $SMART_LIFE" \
                    "percent of life expectancy is left for $DISK_NAME." \
                    "$DO_ACTION"
            fi
        fi

        # find errors where the smart test just stops
        if [ "$LAST_TEST_STATUS" = "Interrupted (host reset)" ]; then
            echo "$DISK_PATH Incomplete test due to disconnection." \
                "Could be a bad cable or broken disk."
        fi

    # print full disk information
    else
        # print all SMART info in one line
        printf "%s " "$DISK_PATH"
        printf "Real.Sec.: %s  " "$SMART_REAL"
        printf "Uncor.: %s  " "$SMART_UNCO"
        printf "Wear Level: %s  " "$SMART_WEAR"
        printf "Life left: %s  " "$SMART_LIFE"
        printf "%s" "$DISK_NAME"
        printf "\n"

        # print results of the last smart test
        local LAST_TEST_STATUS_FORMAT
        LAST_TEST_STATUS_FORMAT=$(echo "$LAST_TEST_STATUS" |
            sed 's/Completed without error/OK/g' |
            sed 's/null/Warning: Never/g')
        printf "%s " "$DISK_PATH"
        printf "Last Test: %s" "$LAST_TEST_STATUS_FORMAT"
        printf "\n"

    fi
}

check_nvme() {
    # parameters
    local DISK_PATH="$1"

    HAS_SMART=$(command -v smartctl)
    if [ -z "${HAS_SMART}" ]; then
        echo "Smartctl is not installed. Please install." >&2
        return 1
    # if smartctl is installed
    else
        # check for the right version
        HAS_VER7=$(smartctl --version | grep "release 7")
        if [ -z "${HAS_VER7}" ]; then
            if [ "$CRITICAL" = "$PARAMETER" ]; then
                :
            else
                echo "$DISK_PATH Warning:" \
                    "Smartctl version lower than 7 is not supportet." >&2
            fi
            return 0
        else
            # check also if jq is installed
            HAS_JSON=$(command -v jq)
            if [ -z "${HAS_JSON}" ]; then
                echo "jq is not installed. Please install." >&2
                return 1
            fi
        fi
    fi

    local SMART_DATA
    SMART_DATA=$(smartctl -j -a "$DISK_PATH")
    local DISK_NAME
    DISK_NAME=$(echo "$SMART_DATA" | jq -r ".model_name")

    local SMART_NVME_WEAR
    local SMART_NVME_STATUS
    local DO_ACTION="Please Replace."
    local STATUS_MSG="Unknown"
    local CRIT_WEAR=90

    SMART_NVME_WEAR=$(smartctl -j -a "$DISK_PATH" |
        jq -r .nvme_smart_health_information_log.percentage_used)
    SMART_NVME_STATUS=$(smartctl -j -a "$DISK_PATH" |
        jq -r .smart_status.passed)
    if [ "$SMART_NVME_STATUS" = "true" ]; then
        STATUS_MSG="OK"
    else
        STATUS_MSG="Bad"
    fi

    # print only critical flash errors
    if [ "$CRITICAL" = "$PARAMETER" ]; then
        # find errors
        if [ "$STATUS_MSG" = "Bad" ]; then
            echo "$DISK_PATH has errors."
        fi

        # find usage
        if [ "$SMART_NVME_WEAR" -gt "$CRIT_WEAR" ]; then
            echo "$DISK_PATH has used $SMART_NVME_WEAR" \
                "percent of its total usage for $DISK_NAME." \
                "$DO_ACTION"
        fi

    # or list everything
    else
        # print all SMART info in one line
        printf "%s " "$DISK_PATH"
        printf "Status: %s  " "$STATUS_MSG"
        printf "Percentage Used: %s  " "$SMART_NVME_WEAR"
        printf "%s" "$DISK_NAME"
        printf "\n"
    fi
}

check_flash() {
    # parameters
    local DISK_PATH="$1"

    # print only critical flash errors
    if [ "$CRITICAL" = "$PARAMETER" ]; then
        :
    # or list everything
    else
        echo "$DISK_PATH Analysing flash storage is not implemented yet"
        # todo: parse dmesg
    fi
}

check_ceph() {
    # parameters
    local DISK_PATH="$1"

    # print only critical errors
    if [ "$CRITICAL" = "$PARAMETER" ]; then
        :
    # or list everything
    else
        echo "$DISK_PATH is part of a CEPH cluster"
    fi
}

check_hw_raid() {
    # print only critical RAID errors
    if [ "$CRITICAL" = "$PARAMETER" ]; then
        megasasctl -HB
    # or list everything
    else
        echo "###### Hardware RAID:"
        megasasctl | sed '/^$/d'
    fi
}

check_sw_raid() {
    MDSTAT="/proc/mdstat"
    # check if there is a software raid at all
    if [ -f "$MDSTAT" ]; then

        # find all md devices
        SW_DISKS=$(grep 'md' $MDSTAT | awk '{print $1}')

        if [ ! "$CRITICAL" = "$PARAMETER" ]; then
            if [ -n "${SW_DISKS}" ]; then
                echo "###### Software RAID:"
            fi
        fi

        # check all software raids
        for f in $SW_DISKS; do
            # check if there are sw raids and mdadm is installed
            HAS_MDADM=$(command -v mdadm)
            if [ -z "${HAS_MDADM}" ]; then
                echo "$f found but mdadm is not installed. Please install." >&2
                return 1
            fi

            # show status
            SW_DISK_PATH="/dev/$f"
            STATUS=$(mdadm --detail "$SW_DISK_PATH" |
                grep -e '^\s*State : ' |
                awk '{ print $NF; }')
            if [ "$STATUS" = "active" ] || [ "$STATUS" = "clean" ]; then
                # print only critical software RAID errors
                if [ ! "$CRITICAL" = "$PARAMETER" ]; then
                    echo "$SW_DISK_PATH OK"
                fi
            else
                echo "$SW_DISK_PATH Warning: $STATUS"
            fi
        done

    fi
}

main() {
    # check if megasasctl is installed
    HAS_RAID=$(command -v megasasctl)
    # check hardware raid
    if [ -n "${HAS_RAID}" ]; then
        check_hw_raid
    fi

    # check software raid
    check_sw_raid

    # check all disks
    if [ "$CRITICAL" != "$PARAMETER" ]; then
        echo "###### Physical disks:"
    fi
    local DISKS
    # get a list of all physical disks
    DISK_INFO=$(lsblk -d -o KNAME,TYPE,SIZE,MODEL | grep disk)
    # check all disks that the OS sees as physical
    DISKS=$(echo "$DISK_INFO" | awk '{print $1}')
    local i
    for i in $DISKS; do
        # Mechanical disks and SSDs in HDD formfactor
        if echo "$i*" | grep -q "sd"; then
            check_disk "/dev/$i"
        # NVME
        elif echo "$i*" | grep -q "nvme"; then
            check_nvme "/dev/$i"
        # Flash storage
        elif echo "$i*" | grep -q "mmc"; then
            check_flash "/dev/$i"
        # Ceph node
        elif echo "$i*" | grep -q "rbd"; then
            check_ceph "/dev/$i"
        # Virtual disk
        elif echo "$i*" | grep -q "vda"; then
            :
        # Unknown
        else
            echo "$i Warning: Unknown disk format." \
                "Please add this disk format to the script."
        fi
    done
}

###### MAIN ###################################################################

main
