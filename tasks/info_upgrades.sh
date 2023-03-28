#!/bin/sh
#info: Check if reboot is required and status of unattended-upgrades
#autoroot

# detect if windows or posix and if user is root
# windows
if [ -n "$(command -v systeminfo)" ]; then
    # must run as build in admin
    if [ "$(id -u 544)" -ne 544 ]; then
        echo 'This script must be run as admin!' >&2
        exit 1
    fi
# posix
else
    # must run as root
    if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run as root!' >&2
        exit 1
    fi
fi

if [ -f /var/run/reboot-required ]; then
    echo "Reboot required"
fi

if [ -z "$(command -v unattended-upgrades)" ]; then
    echo "Skipping, missing package: unattended-upgrades"
else
    echo "unattended-upgrades status:"
    # shellcheck disable=SC2002
    cat "/etc/apt/apt.conf.d/50unattended-upgrades" |
        grep -v // | grep -v -e '^$'
fi

if [ -z "$(command -v needrestart)" ]; then
    echo "Skipping, missing package: needrestart"
else
    LIST_NEEDRESTART=$(needrestart -qr l | sed '/^ *$/d')
    if [ -n "$LIST_NEEDRESTART" ]; then
        echo "Running outdated binaries:"
        echo "$LIST_NEEDRESTART"
    fi
fi

#todo:
#windows: https://www.nextofwindows.com/how-to-tell-if-a-remote-computer-needs-reboot