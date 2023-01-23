#!/bin/sh
#info: Remove .ssh folders for root and all users with a home directory
#autoroot

# must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

USERS="/home/*"
for i in $USERS; do
    rm -rf "$i"/.ssh
done

rm -rf /root/.ssh
