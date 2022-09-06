#!/bin/sh
#info: Show diskspace usage over 90 percent. For all /dev/sd* devices
#autoroot
# shellcheck disable=SC2039

###### GLOBAL VARIABLES #######################################################

### INIT ######################################################################
# must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

###### FUNCTIONS ##############################################################

check_space() {
    # parameters
    local DISK_PATH="$1"
    local DISK_INFO
    local DISK_MOUNT
    local DISK_USAGE

    # get partition space usage
    DISK_INFO=$(df "$DISK_PATH" | tail -n 1)

    if [ "$DISK_INFO" = "" ]; then
        echo "Failed to look at diskspace usage on $DISK_PATH"
    else
        DISK_NAME=$(echo "$DISK_PATH" | sed 's|/dev/||')
        DISK_MOUNT=$(echo "$DISK_INFO" | awk '{print $6}')
        DISK_USAGE=$(echo "$DISK_INFO" | awk '{print $5}' | sed 's/%//')

        # print full partition space usage
        if [ "$DISK_USAGE" -eq "100" ]; then
            echo "Disk $DISK_NAME on $DISK_MOUNT is full!"
        elif [ "$DISK_USAGE" -gt "90" ]; then
            echo "Disk $DISK_NAME on $DISK_MOUNT" \
                "is almost full at $DISK_USAGE percent"
        fi
    fi
}

main() {
    # check all disks
    local PARTITIONS
    PARTITIONS=$(ls /dev/sd**[a-z][0-9])

    local i
    for i in $PARTITIONS; do
        check_space "$i"
    done
}

###### MAIN ###################################################################

main
