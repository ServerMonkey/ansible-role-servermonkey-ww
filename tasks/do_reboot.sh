#!/bin/sh
#info: Reboot system
#autoroot

# must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

/sbin/shutdown -r now
