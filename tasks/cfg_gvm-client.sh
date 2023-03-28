#!/bin/sh
#info: Configure a Windows client to be Greenbone/OpenVAS compliant
#info: , required for SMB auth scans
#based on: https://docs.greenbone.net/GSM-Manual/gos-22.04/en/scanning.html#requirements-on-target-systems-with-microsoft-windows

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

# disable UAC remote restrictions
regtool set "\HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\LocalAccountTokenFilterPolicy" -d "1"

# enable and start remote registry
sc start remoteregistry start=auto 1>/dev/null

if echo "$VIN_VER" | grep -q "Windows XP"; then
    # Disable XPs 'Simple File Sharing'
    regtool set "\HKLM\SYSTEM\CurrentControlSet\Control\Lsa\forceguest" -d "0"
fi
