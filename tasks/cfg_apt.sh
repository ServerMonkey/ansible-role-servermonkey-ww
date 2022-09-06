#!/bin/sh
#info: Configure the Debian sources list, always includes backports
#arg: prop,exp,local
#arginfo: Additionally enable custom repos, like proposed and/or experimental
#autoroot

# must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

OS=$(grep "^NAME=" </etc/os-release | sed 's/"//g' | cut -d'=' -f 2 | awk '{print $1}')
CODENAME=$(grep "^VERSION_CODENAME=" </etc/os-release | cut -d'=' -f 2)
SOURCE="/etc/apt/sources.list"
REPOS="main contrib non-free"
CUSTOM="$1"

if [ -n "${2}" ]; then
    echo "Only enter a continues parameter, like: pro,exp,local"
    exit 1
fi

# set variables
case $OS in
Raspbian)
    case $CODENAME in
    buster)
        exit 0
        ;;
    bullseye)
        exit 0
        ;;
    *)
        echo "This release is not supported, please update this script."
        exit 1
        ;;
    esac
    ;;
Debian)
    case $CODENAME in
    buster)
        REPO="deb http://deb.debian.org/debian"
        REPO_SEC="deb http://security.debian.org/debian-security/"
        REPO_SEC_SUFFIX="/updates"
        ;;
    bullseye)
        REPO="deb http://deb.debian.org/debian"
        REPO_SEC="$REPO-security/"
        REPO_SEC_SUFFIX="-security"
        ;;
    *)
        echo "This release is not supported, please update this script."
        exit 1
        ;;
    esac
    ;;
esac

# add repos
case $OS in
Raspbian)
    exit 0
    ;;
Debian)
    case $CODENAME in
    buster | bullseye)
        # mainline
        echo "$REPO $CODENAME $REPOS" >$SOURCE
        # security upgrades
        echo "$REPO_SEC $CODENAME$REPO_SEC_SUFFIX $REPOS" >>$SOURCE
        # upgrades
        echo "$REPO $CODENAME-updates $REPOS" >>$SOURCE
        # backports
        echo "$REPO $CODENAME-backports $REPOS" >>$SOURCE
        # experimental
        if echo "$CUSTOM" | grep -q "exp"; then
            echo "$REPO experimental $REPOS" >>$SOURCE
        fi
        # proposed
        if echo "$CUSTOM" | grep -q "prop"; then
            echo "$REPO $CODENAME-proposed-updates $REPOS" >>$SOURCE
        fi
        # local/offline
        if echo "$CUSTOM" | grep -q "local"; then
            REPO_OFF="/opt/packages/"
            mkdir -p $REPO_OFF || exit 1
            touch "$REPO_OFF"Packages
            echo "deb [trusted=yes] file://$REPO_OFF ./" >>$SOURCE
        fi
        ;;
    esac
    ;;
esac

# force update, fixes bugs
apt-get update -qqqy
