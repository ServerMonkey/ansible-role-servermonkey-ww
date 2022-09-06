#!/bin/sh
#info: Show the CPUs virtualization capabilities
#autoroot

TEST_AES=$(grep -m1 -o aes /proc/cpuinfo)
TEST_IOMMU=$(dmesg | grep DMAR:)
TEST_VIRT=$(lscpu | grep Virtualization: | awk '{print $2}')

# VT-d and IOMMU
if [ -z "${TEST_IOMMU}" ]; then
    IOMMU="VT-d/IOMMU: FAIL"
else
    IOMMU="VT-d/IOMMU: OK  "
fi

# AES
if [ -z "${TEST_AES}" ]; then
    AES="AES: FAIL"
else
    AES="AES: OK  "
fi

# VT-x
if [ -z "${TEST_VIRT}" ]; then
    VIRT="VIRT: FAIL"
else
    VIRT="$TEST_VIRT: OK  "
fi

# show results
echo "$AES   $IOMMU   $VIRT"
