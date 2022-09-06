#!/bin/sh
#info: Check the status of unattended-upgrades

SMART_INSTALLED=$(command -v unattended-upgrades)
if [ -z "${SMART_INSTALLED}" ]; then
    echo "Unattended-upgrades is not installed."
    exit 0
fi
# shellcheck disable=SC2002
cat "/etc/apt/apt.conf.d/50unattended-upgrades" | grep -v // | grep -v -e '^$'
