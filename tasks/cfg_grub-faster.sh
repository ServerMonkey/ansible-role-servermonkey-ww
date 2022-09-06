#!/bin/sh
#info: Set GRUB timeout to 1 second
#autoroot

# must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

GRUB="/etc/default/grub"

# skip if there is no grub
if [ ! -f "$GRUB" ]; then
    exit 0
fi

if ! grep -Fxq "GRUB_TIMEOUT=1" $GRUB ; then
    sed -i "/GRUB_TIMEOUT=/c\GRUB_TIMEOUT=1" $GRUB
    update-grub 2>/dev/null || exit 1
fi
