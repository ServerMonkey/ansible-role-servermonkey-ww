#!/bin/sh
#info: Show basic information about the OS (cygwin comp)

# not linux
if [ -z "$(command -v lsb_release)" ]; then
    # windows
    if [ -n "$(command -v systeminfo)" ]; then
        OS=$(systeminfo 2>/dev/null | sed '/^ *$/d')
        OS_DIST=$(echo "$OS" | grep "^OS Name:" |
            awk -F ':' '{print $2}' |
            awk '{$1=$1;print}' |
            sed 's/Professional/Pro/g' |
            sed 's/Microsoft/MS/g')
        OS_RES=$(echo "$OS" | grep "^OS Version:" |
            awk -F ':' '{print $2}' |
            awk '{$1=$1;print}' |
            sed 's/Service Pack/SP/g')
        OS_CODE=""
        # list installation date
        # shellcheck disable=SC2012
        OS_INSTALLED=$(ls --time-style="+%Y-%m-%d %H:%M" -alct "C:/WINDOWS" |
            tail -1 | awk '{print $6, $7}')
    # not posix or windows
    else
        OS_DIST="Unknown"
        OS_RES="Unknown"
        OS_CODE="Unknown"
    fi

# linux
else
    OS=$(lsb_release -a 2>/dev/null)
    OS_DIST=$(echo "$OS" | grep Distributor | awk '{print $3}')
    OS_RES=$(echo "$OS" | grep Release | awk '{print $2}')
    OS_CODE=$(echo "$OS" | grep Codename | awk '{print $2}')
    # list installation date
    # shellcheck disable=SC2012
    OS_INSTALLED=$(ls --time-style="+%Y-%m-%d %H:%M" -alct / |
        tail -1 | awk '{print $6, $7}')
fi

# list
echo "Installed: $OS_INSTALLED  OS: $OS_DIST $OS_RES $OS_CODE"
