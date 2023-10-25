#!/bin/sh
#info: Configure the Debian sources list, for Debian and KALI
#info: . Always includes contrib, non-free, updates and security.
#arg: back,prop,local,cdrom,offline,src,roll
#arginfo: Additionally enable custom repos, like proposed or CD/DVD-drive
#autoroot

# back = Debian backports (gets you newer software)
# prop = Debian proposed (gets you even newer software, but can be buggy)
# local = add your custom packages to /opt/packages/
# cdrom = add /dev/cdrom to local repo (does not work for KALI)
# offline = does not add any repos, but local and cdrom will work
# src = add source for all repos
# roll = KALI rolling, can be buggy, without will use latest snapshot instead

# abort on any error
set -e

# must run as root
# skip on windows
if [ -n "$(command -v systeminfo)" ]; then
    echo "Skipping cfg_apt: Windows is not supported"
    exit 0
# posix
else
    if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run as root!' >&2
        exit 1
    fi
fi

OS=$(grep "^NAME=" </etc/os-release | sed 's/"//g' | cut -d'=' -f 2 |
    awk '{print $1}')
CODENAME=$(grep "^VERSION_CODENAME=" </etc/os-release | cut -d'=' -f 2 |
    sed 's|\x27||g' | sed 's|\x22||g')
SRC="/etc/apt/sources.list"
EXTRA_REPOS="$1"
PING_HOST=""

# don't allow more than one argument/parameter
if [ -n "${2}" ]; then
    echo "Only enter one continues parameter, example: back,prop"
    exit 1
fi

info_na_os() {
    echo "Skipping cfg_apt: unsupported OS '$OS'"
    exit 0
}

info_na_rel() {
    echo "Skipping cfg_apt: unsupported OS '$OS' with release '$CODENAME'"
    exit 0
}

error() {
    echo "Error: $1"
    exit 1
}

add_repo() {
    echo "deb $REPO_BASE""$*" >>$SRC
    if echo "$EXTRA_REPOS" | grep -q "src"; then
        echo "deb-src $REPO_BASE""$*" >>$SRC
    fi
}

# set variables to the most stable release
case $OS in
Debian)
    REPO_BASE="http://deb.debian.org/debian"
    case $CODENAME in
    buster)
        REPO_SEC_SUFFIX=""
        COMPONENT="main contrib non-free"
        ;;
    bullseye)
        REPO_SEC_SUFFIX="-security"
        COMPONENT="main contrib non-free"
        ;;
    bookworm)
        REPO_SEC_SUFFIX="-security"
        if echo "$EXTRA_REPOS" | grep -q "offline" &&
            echo "$EXTRA_REPOS" | grep -q "cdrom"; then
            COMPONENT="main non-free-firmware"
        else
            COMPONENT="main contrib non-free non-free-firmware"
        fi
        ;;
    trixie)
        REPO_SEC_SUFFIX="-security"
        if echo "$EXTRA_REPOS" | grep -q "offline" &&
            echo "$EXTRA_REPOS" | grep -q "cdrom"; then
            COMPONENT="main non-free-firmware"
        else
            COMPONENT="main contrib non-free non-free-firmware"
        fi
        ;;
    *)
        info_na_rel
        ;;
    esac
    ;;
Kali)
    case $CODENAME in
    kali-rolling)
        REPO_BASE="http://http.kali.org/kali"
        COMPONENT="main contrib non-free non-free-firmware"
        ;;
    *)
        info_na_rel
        ;;
    esac
    ;;
Raspbian)
    case $CODENAME in
    buster)
        info_na_rel
        ;;
    bullseye)
        info_na_rel
        ;;
    bookworm)
        info_na_rel
        ;;
    trixie)
        info_na_rel
        ;;
    *)
        info_na_rel
        ;;
    esac
    ;;
*)
    info_na_os
    ;;
esac

# add repos
case $OS in
Raspbian)
    info_na_os
    ;;
Debian)
    case $CODENAME in
    buster | bullseye | bookworm | trixie)
        # remove old configuration and add ansible header
        echo "# BEGIN - cfg_apt" >$SRC || error "Failed to create $SRC"
        #
        # offline
        if echo "$EXTRA_REPOS" | grep -q "offline"; then
            # skip adding any repos in offline mode
            :
        # online/default
        else
            # mainline
            add_repo " $CODENAME $COMPONENT"
            # upgrades
            add_repo " $CODENAME-updates $COMPONENT"
            # backports
            if echo "$EXTRA_REPOS" | grep -q "back"; then
                add_repo " $CODENAME-backports $COMPONENT"
            fi
            # proposed
            if echo "$EXTRA_REPOS" | grep -q "prop"; then
                add_repo " $CODENAME-proposed-updates $COMPONENT"
            fi
            # security upgrades
            add_repo "-security $CODENAME$REPO_SEC_SUFFIX $COMPONENT"
            # ping host
            PING_HOST="deb.debian.org"
        fi
        #
        # local
        if echo "$EXTRA_REPOS" | grep -q "local"; then
            REPO_OFF="/opt/packages/"
            mkdir -p $REPO_OFF || error "Failed to create $REPO_OFF"
            touch "$REPO_OFF"Packages
            echo "deb [trusted=yes] file://$REPO_OFF ./" >>$SRC
        fi
        #
        # cdrom
        if echo "$EXTRA_REPOS" | grep -q "cdrom"; then
            # verify cdrom device
            blkid "/dev/cdrom" >/dev/null
            # shellcheck disable=SC2181
            if [ "$?" != 0 ]; then
                echo "Skipping cfg_apt for 'cdrom': No hardware device found"
            else
                REPO_CD="/media/cdrom-apt-repo-$CODENAME/"

                # add repo
                mkdir -p "$REPO_CD" || error "Failed to create $REPO_CD"
                echo "deb [trusted=yes] file://$REPO_CD $CODENAME $COMPONENT" \
                    >>$SRC || error "Failed to add cdrom repo to $SRC"

                # automount on boot
                if ! grep -q "/dev/cdrom" </etc/fstab; then
                    # shellcheck disable=SC2129
                    echo "# BEGIN - CDROM" >>/etc/fstab || error "add to fstab"
                    echo "/dev/cdrom $REPO_CD iso9660 ro,user,auto 0 0" \
                        >>/etc/fstab
                    echo "# END - CDROM" >>/etc/fstab
                fi

                # manual mount now
                if ! findmnt "$REPO_CD" 1>/dev/null; then
                    mount -o ro /dev/cdrom "$REPO_CD"
                fi

                # verify
                if ! findmnt "$REPO_CD" 1>/dev/null; then
                    error "failed to mount $REPO_CD"
                fi
            fi
        fi
        #
        # close ansible header
        echo "# END - cfg_apt" >>$SRC
        ;;
    esac
    ;;
Kali)
    case $CODENAME in
    kali-rolling)
        # remove old configuration and add ansible header
        echo "# BEGIN - cfg_apt" >$SRC
        #
        # offline
        if echo "$EXTRA_REPOS" | grep -q "offline"; then
            # don't update kali in offline mode
            echo "# Kali repos are not avaliable in offline mode" >>$SRC
        #
        # online/default
        else
            # rolling (similar to Debian testing/unstable)
            if echo "$EXTRA_REPOS" | grep -q "roll"; then
                add_repo " $CODENAME kali-rolling $COMPONENT"
            # snapshot (similar to Debian stable/mainline)
            else
                add_repo " $CODENAME last-snapshot $COMPONENT"
            fi
            # ping host
            PING_HOST="http.kali.org"
        fi
        #
        # local
        if echo "$EXTRA_REPOS" | grep -q "local"; then
            REPO_OFF="/opt/packages/"
            mkdir -p $REPO_OFF || error "Failed to create $REPO_OFF"
            touch "$REPO_OFF"Packages
            echo "deb [trusted=yes] file://$REPO_OFF ./" >>$SRC
        fi
        #
        # close ansible header
        echo "# END - cfg_apt" >>$SRC
        ;;
    esac
    ;;
esac

# ping test
if [ -n "$PING_HOST" ]; then
    ping -c1 "$PING_HOST" 1>/dev/null 2>&1 ||
        error "Failed to reach $PING_HOST"
fi

# force update, fixes bugs
apt-get update -qqy || error "Failed to update apt"
