#!/bin/sh
#info: List errors from the Linux kernel ring buffer, excludes false-positives
#autoroot

# must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

# check systems entropy
FILE_ENTROPY="/proc/sys/kernel/random/entropy_avail"
if [ ! -f "$FILE_ENTROPY" ]; then
    echo "Failed to access $FILE_ENTROPY"
else
    ENTROPY=$(cat "$FILE_ENTROPY")
    if [ "$ENTROPY" -lt "200" ]; then
        echo "There is too little entropy availabe: $ENTROPY"
    fi
fi

# check log for too many audit logs
# lets say below 20 is normal behavior
AUDIT_COUNT=$(dmesg | grep -c "audit:")
if [ "$AUDIT_COUNT" -gt 20 ]; then
    echo "Error: Too many Audit logs, counting: $AUDIT_COUNT in ring buffer"
fi

# check log for kauditd overflow
# audit logs record each time a file is read or written or otherwise modified
AUDIT_OVERFLOW=$(dmesg | grep "hold queue overflow" | awk '{print $3,$4,$5,$6}' | uniq)
if [ "$AUDIT_OVERFLOW" = "kauditd hold queue overflow" ]; then
    echo "Error: Audit log overflow: kauditd hold queue overflow"
fi

# list system errors
dmesg -T | grep \
    -e "error" \
    -e "Error" \
    -e "fatal" \
    -e "Fatal" \
    -e "critical" \
    -e "Critical" \
    -e "fs with errors" \
    -e "BUG" \
    -e "overlayfs: failed" \
    -e "overlayfs: invalid" \
    -e "unable to" |
    uniq |
    sed \
        -e '/error 13/d' \
        -e '/No route to host/d' \
        -e '/device descriptor/d' \
        -e '/Error d5 on cmd 24/d' \
        -e '/Hardware Error/d' \
        -e '/ETag/d' \
        -e '/failed on NFS/d' \
        -e '/(ATA bus error)/d' \
        -e '/{ UnrecovData Handshk }/d' \
        -e '/RPC call returned error 512/d' \
        -e '/errors=remount-ro/d' \
        -e '/usb 1-1.2: device descriptor read\/64, error -32/d' \
        -e '/usb 1-1.2: device not accepting address/d' \
        -e '/unable to enumerate USB device/d' \
        -e '/error 4 in VBoxManage/d' \
        -e '/error 4 in vboxwebsrv/d' \
        -e '/unable to get SMM Dell signature/d' \
        -e '/Correctable Errors collector initialized/d'
