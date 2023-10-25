#!/bin/sh
#info: Detect GPU vendor

if [ -z "$(command -v lspci)" ]; then
	echo "Failed to find lspci" >&2
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
elif echo "$GPU" | grep -q "MGA G200"; then
	echo "Matrox"
elif echo "$GPU" | grep -q ASPEED; then
	echo "ASPEED"
else
	echo "Failed to detect GPU: $GPU" >&2
	echo "Please update this script" >&2
	exit 1
fi
