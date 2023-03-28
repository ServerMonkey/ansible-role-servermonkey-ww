#!/bin/sh
#info: Show disks, filesystem and usage

df -lh --output=source,target,fstype,pcent \
    -x tmpfs -x squashfs -x devtmpfs -x overlay | tail -n +2

#check_space() {
#    # parameters
#    local DISK_PATH="$1"
#    local DISK_INFO
#    local DISK_MOUNT
#    local DISK_USAGE
#
#    # get partition space usage
#    DISK_INFO=$(df "$DISK_PATH" | tail -n 1)
#
#    if [ "$DISK_INFO" = "" ]; then
#        echo "Failed to look at diskspace usage on $DISK_PATH"
#    else
#        DISK_NAME=$(echo "$DISK_PATH" | sed 's|/dev/||')
#        DISK_MOUNT=$(echo "$DISK_INFO" | awk '{print $6}')
#        DISK_USAGE=$(echo "$DISK_INFO" | awk '{print $5}' | sed 's/%//')
#
#        # print full partition space usage
#        if [ "$DISK_USAGE" -eq "100" ]; then
#            echo "Disk $DISK_NAME on $DISK_MOUNT is full!"
#        elif [ "$DISK_USAGE" -gt "90" ]; then
#            echo "Disk $DISK_NAME on $DISK_MOUNT" \
#                "is almost full at $DISK_USAGE percent"
#        fi
#    fi
#}