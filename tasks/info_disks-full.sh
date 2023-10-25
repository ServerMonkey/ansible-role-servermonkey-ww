#!/bin/sh
#info: Check if only 3 percent or less of diskspace are available on disks
#autoroot

set -e

# args
# at how many percentage of disk use to warn
CRIT_PERC="$1"
if [ -z "$CRIT_PERC" ]; then
    CRIT_PERC=97
fi

# get a list of disks
TMP_DISKS=$(mktemp)
lsblk -nlo NAME,FSAVAIL,FSUSE%,MOUNTPOINT >"$TMP_DISKS" || exit 1

# iterate trough a file
while read -r line; do
    DISK_NAME=$(echo "$line" | awk '{print $1}')
    DISK_FREE=$(echo "$line" | awk '{print $2}')
    DISK_USED=$(echo "$line" | awk '{print $3}' | tr -d %)
    DISK_MONT=$(echo "$line" | awk '{print $4}')

    # only test disks in use
    if [ -n "$DISK_USED" ]; then
        # skip loopback devices
        if echo "$DISK_NAME" | grep -q ^loop; then
            :
        elif [ "$DISK_USED" -ge "$CRIT_PERC" ]; then
            echo "Disk $DISK_NAME $DISK_MONT is full at $DISK_USED%," \
                "only $DISK_FREE of space left"
        fi
    fi
done <"$TMP_DISKS"

# clean up
rm -f "$TMP_DISKS" || exit 1
