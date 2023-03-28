#!/bin/sh
#info: Enable 'File and Printer Sharing' in Windows firewall

# must run as admin
if [ -n "$(command -v systeminfo)" ]; then
    if [ "$(id -u 544)" -ne 544 ]; then
        echo 'This script must be run as admin!' >&2
        exit 1
    fi
else
    exit 0
fi

VIN_VER=$(systeminfo | grep "OS Name:" | awk -F ':' '{print $2}' |
    awk '{$1=$1;print}')

# allow 'File and Printer Sharing' in firewall
# XP
if echo "$VIN_VER" | grep -q "Windows XP"; then
    netsh firewall set service type=fileandprint mode=enable 1>/dev/null
# 7 and later
else
    netsh advfirewall firewall set rule group="File and Printer Sharing" \
        new enable=Yes
fi
