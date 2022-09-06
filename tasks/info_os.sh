#!/bin/sh
#info: Show basic information about the OS, version

# list crate OS version
OS=$(lsb_release -a 2>/dev/null)
OS_DIST=$(echo "$OS" | grep Distributor | awk '{print $3}')
OS_RES=$(echo "$OS" | grep Release | awk '{print $2}')
OS_CODE=$(echo "$OS" | grep Codename | awk '{print $2}')

# list installation date
# shellcheck disable=SC2012
OS_INSTALLED=$(ls --time-style="+%Y-%m-%d %H:%M" -alct / | tail -1 | awk '{print $6, $7}')

# list
echo "Installed: $OS_INSTALLED  OS: $OS_DIST $OS_RES ($OS_CODE)"
