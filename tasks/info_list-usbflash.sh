#!/bin/sh
#info: List remove block devices, like USB flashstorage

# get list of removabe devices
USBKEYS=$(
    grep -Hv ^0$ /sys/block/*/removable |
        sed s/removable:.*$/device\\/uevent/ |
        xargs grep -H ^DRIVER=sd |
        sed s/device.uevent.*$/size/ |
        xargs grep -Hv ^0$ |
        cut -d / -f 4
)

# list devices
for i in $USBKEYS; do
    DEVICE_VENDOR=$(cat /sys/block/"$i"/device/vendor)
    DEVICE_NAME=$(cat /sys/block/"$i"/device/model)
    DEVICE_SIZE=$(lsblk -d -n -o SIZE /dev/"$i")
    echo "$i $DEVICE_SIZE $DEVICE_VENDOR$DEVICE_NAME"
done
