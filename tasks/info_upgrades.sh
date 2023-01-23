#!/bin/sh
#info: Check if reboot is required and status of unattended-upgrades

# must run as root
if [ "$(id -u)" -ne 0 ]; then
	echo 'This script must be run as root!' >&2
	exit 1
fi

if [ -f /var/run/reboot-required ]; then
	echo "Reboot required"
fi

if [ -z "$(command -v unattended-upgrades)" ]; then
	echo "Skipping, missing package: unattended-upgrades"
else
	echo "unattended-upgrades status:"
	# shellcheck disable=SC2002
	cat "/etc/apt/apt.conf.d/50unattended-upgrades" |
		grep -v // | grep -v -e '^$'
fi

if [ -z "$(command -v needrestart)" ]; then
	echo "Skipping, missing package: needrestart"
else
	LIST_NEEDRESTART=$(needrestart -qr l | sed '/^ *$/d')
	if [ -n "$LIST_NEEDRESTART" ]; then
		echo "Running outdated binaries:"
		echo "$LIST_NEEDRESTART"
	fi
fi
