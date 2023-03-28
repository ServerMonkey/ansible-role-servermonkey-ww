#!/bin/sh
#info: Trim disk, replaces unused disk space with zeros, good for compacting VMs
#autoroot

# windows
if [ -n "$(command -v systeminfo)" ]; then
    # must run as build in admin
    if [ "$(id -u 544)" -ne 544 ]; then
        echo 'This script must be run as admin!' >&2
        exit 1
    fi

    #todo, for ps: PS C:\>Optimize-Volume -DriveLetter H -ReTrim -Verbose (win 10)
    # https://www.windowscentral.com/how-ensure-trim-enabled-windows-10-speed-ssd-performance
    # try "defrag D: /L" on XP ?
    # https://pve.proxmox.com/wiki/Shrink_Qcow2_Disk_Files
    echo "Windows is not supported" >&2
    exit 1
# posix
else
    # must run as root
    if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run as root!' >&2
        exit 1
    fi

    if [ -n "$(command -v fstrim)" ]; then
        fstrim -av
    else
        echo "fstrim is not installed"
        exit 1
    fi
fi
