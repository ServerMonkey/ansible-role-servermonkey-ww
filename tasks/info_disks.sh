#!/bin/sh
#info: Show all disks, filesystem and usage

df -lh --output=source,target,fstype,pcent \
    -x tmpfs -x squashfs -x devtmpfs -x overlay | tail -n +2
