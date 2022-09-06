#!/bin/sh
#info: Show RAM detected by OS and percentage used

RAM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
RAM_USED=$(free -t | awk 'NR == 2 {printf("%.2f%"), $3/$2*100}')

echo "Memory  Total: $RAM_TOTAL  Used: $RAM_USED"
