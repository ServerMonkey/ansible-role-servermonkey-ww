#!/bin/sh
#info: List current system warnings from the kernel ring buffer
#autoroot

# windows
if [ -n "$(command -v systeminfo)" ]; then
    echo "Windows is not supported" >&2
    exit 1
# posix must run as root
elif [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

# list current system warnings
dmesg -T | grep \
    -e "warning" \
    -e "Warning" \
    -e "fail" \
    -e "Fail" \
    -e "invalid" \
    -e "Hardware Error" |
    uniq |
    sed \
        -e '/nf_conncount -71/d' \
        -e '/failed with exit code 1./d' \
        -e '/Failed to process device/d' \
        -e '/ACPI BIOS Warning (bug): Invalid length for FADT/d' \
        -e '/failed to assign mem/d' \
        -e '/_OSC failed/d' \
        -e '/mounting unchecked fs/d' \
        -e '/running e2fsck is recommended/d' \
        -e '/Error]: Machine check /d' \
        -e '/Error]: CPU /d' \
        -e '/Error]: TSC /d' \
        -e 's/failed command: WRITE FPDMA QUEUED/Broken SATA cable or bad chipset design/g' \
        -e 's/mce: \[Hardware Error\]: PROCESSOR/CPU error/g' \
        -e 's/SOCKET 0 APIC 0 microcode 24/Kernel is incompatible with APIC chipset/g' \
        -e 's/missing or invalid SUBNQN field./Has crappy firmware, try to update firmware or kernel./g' \
        -e '/failed to assign \[mem size/d' \
        -e '/CPU error 0:306c3/d' \
        -e '/CPU error 0:206d7/d' \
        -e '/CPU error 0:906e9/d' \
        -e '/overlayfs: failed/d' \
        -e '/overlayfs: invalid/d' \
        -e '/Fast TSC calibration failed/d' \
        -e '/Using Queued invalidation/d' \
        -e '/failed to load iwl-debug-yoyo.bi/d' \
        -e '/i8042: Warning: Keylock active/d' \
        -e '/split lock detection: warning/d' \
        -e '/unable to get SMM Dell signature/d' \
        -e '/DMA domain TLB invalidation/d' \
        -e '/PNP0A03:00: fail to add MMCONFIG/d' \
        -e '/urandom warning(s) missed due to ratelimiting/d'
