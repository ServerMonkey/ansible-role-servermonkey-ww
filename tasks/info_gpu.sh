#!/bin/sh
#info: Show OpenGL and Vulkan information
#autoroot

# alt with error
# windows
if [ -n "$(command -v systeminfo)" ]; then
    echo "Windows is not supported" >&2
    exit 1
# posix must run as root
elif [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

echo "[DISPLAYS]"
DISPLAYS=$(ps a | grep Xorg | grep -v grep | awk '{print $6}')
if [ -n "$DISPLAYS" ]; then
	echo "$DISPLAYS"
else
	echo "No Xorg session found"
fi
echo ""

echo "[GPU]"
GPU_PCI_ID=$(lspci | grep VGA | awk '{print $1}')
for GPUS in $GPU_PCI_ID; do
	lspci -v -s "$GPUS"
done
echo ""

echo "[OpenGL]"
# file does not exist
if [ -f "/var/log/Xorg.0.log" ]; then
	grep glamor /var/log/Xorg.0.log | grep "acceleration enabled"
else
	echo "No Xorg session found"
fi
echo ""

echo "[Vulkan]"
if [ -z "$(command -v vulkaninfo)" ]; then
	echo "vulkaninfo not installed"
else
	VULKAN_INFO=$(vulkaninfo --summary 2>/dev/null)
	echo "$VULKAN_INFO" | grep "VK_LAYER"
	echo "$VULKAN_INFO" | grep "deviceType"
	echo "$VULKAN_INFO" | grep "deviceName"
fi
echo ""

echo "[Vulkan driver]"
# check which vulkan implementations are installed

# folder does not exist
if [ -d "/usr/share/vulkan/icd.d/" ]; then
	VULKAN_DRIVERS=$(find /usr/share/vulkan/icd.d/*.json 2>/dev/null)
	if [ -n "$VULKAN_DRIVERS" ]; then
        for i in $VULKAN_DRIVERS; do
            if echo "$i" | grep -q "lvp_icd"; then
                echo "Lavapipe (software acceleration)"
            elif echo "$i" | grep -q "intel_icd"; then
                echo "Intel"
            elif echo "$i" | grep -q "radeon_icd"; then
                echo "Radeon"
            else
                echo "Unknown: $i"
            fi
        done
    else
        echo "No 'Installable Client Driver' found"
    fi
else
	echo "No 'Installable Client Driver' found"
fi

# search for your GPU:
#https://www.khronos.org/conformance/adopters/conformant-products/vulkan
#https://vulkan.gpuinfo.org/  # write a wget script!
#or compare here: https://wiki.gentoo.org/wiki/Vulkan
