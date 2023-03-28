#!/bin/sh
#info: Clear the kernel buffer
#autoroot

# windows
if [ -n "$(command -v systeminfo)" ]; then
    echo "Windows is not supported" >&2
    exit 1
fi

dmesg -C
