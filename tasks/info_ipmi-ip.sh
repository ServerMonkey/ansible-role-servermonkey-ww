#!/bin/sh
#info: Show the IPMI adress and MAC via OS ipmitool
#autoroot

# must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

if [ -z "$(command -v ipmitool)" ]; then
    echo "ipmitool is not installed. Install to make this script work."
    exit 1
fi

IPMI_DATA=$(ipmitool lan print 2>&1 | sed '/failed: Destination unavailable/d')
IPMI_IP=$(echo "$IPMI_DATA" | grep -e 'IP Address  ' | awk '{print $4}')
IPMI_MAC=$(echo "$IPMI_DATA" | grep -e 'MAC Address  ' | awk '{print $4}')

# if there is no data
if [ -z "$IPMI_MAC" ]; then
    echo "No IPMI MAC adress available"
else
    echo "IPMI-IP: $IPMI_IP   MAC: $IPMI_MAC"
fi
