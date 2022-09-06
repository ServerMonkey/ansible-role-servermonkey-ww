#!/bin/sh
#info: Show overall CPU usage in percent

CPU_TOTAL=$(top -bn1 | grep "Cpu(s)" |
    sed "s/.*, *\([0-9.]*\)%* id.*/\1/" |
    awk '{print 100 - $1"%"}')

CPU_SINCE_BOOT=$(grep 'cpu ' /proc/stat |
    awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}')

echo "CPU  Used: $CPU_TOTAL  Since boot: $CPU_SINCE_BOOT"
