#!/bin/sh
#info: Remove .ssh folders for root and all users with a home directory
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

USERS="/home/*"
for i in $USERS; do
    rm -rf "$i"/.ssh
done

rm -rf /root/.ssh
