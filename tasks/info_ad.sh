#!/bin/sh
#info: Check if host is part of ActiveDirectory

KRB_CFG="/etc/krb5.conf"

# check if part of AD
if [ ! -f "$KRB_CFG" ]; then
    echo "ActiveDirectory: NO"
    exit 0
fi

# check what AD
REALM=$(grep default_realm <"$KRB_CFG" | awk '{print $3}')
echo "ActiveDirectory: YES - $REALM"
