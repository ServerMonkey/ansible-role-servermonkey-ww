#!/bin/sh
#info: Detect GPU vendor

if [ -z "$(command -v lspci)" ]; then
	echo "Failed to find lspci"
	exit 1
fi

GPU=$(lspci | grep 'VGA compatible controller')
if echo "$GPU" | grep -q ATI; then
	echo "AMD"
elif echo "$GPU" | grep -q AMD; then
	echo "AMD"
elif echo "$GPU" | grep -q NVIDIA; then
	echo "NVIDIA"
elif echo "$GPU" | grep -q Intel; then
	echo "INTEL"
elif echo "$GPU" | grep -q QXL; then
	echo "QXL"
elif echo "$GPU" | grep -q VMware; then
	echo "VMware"
else
	echo "Failed to detect GPU: $GPU"
	echo "Please update this script"
	exit 1
fi
