#!/bin/sh
#info: List all disks/blockdevices

if [ -z "$(command -v lsblk)" ]; then
    echo "lsblk is not installed. Install to make this script work."
    exit 1
fi

lsblk
