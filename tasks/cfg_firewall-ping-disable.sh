#!/bin/sh
#info: Disable ping from other hosts in Windows firewall

# must run as build in admin
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

# XP
if echo "$VIN_VER" | grep -q "Windows XP"; then
    netsh firewall set icmpsetting 8 disable 1>/dev/null
# 7 and later
else
    netsh advfirewall firewall add rule \
        name="ICMP Allow incoming V4 echo request" \
        protocol=icmpv4:8,any dir=in action=block

    netsh advfirewall firewall add rule \
        name="ICMP Allow incoming V6 echo request" \
        protocol=icmpv6:8,any dir=in action=block
fi
