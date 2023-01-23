#!/bin/sh
#info: Reboot system (cygwin comp)
#autoroot

# windows
if [ -n "$(command -v systeminfo)" ]; then
    # must run as build in admin
    if [ "$(id -u 544)" -ne 544 ]; then
        echo 'This script must be run as admin!' >&2
        exit 1
    fi
    sh -c "shutdown -r -t 3"
# posix
else
    # must run as root
    if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run as root!' >&2
        exit 1
    fi
    sh -c "sleep 3 && shutdown -r now" &
fi
