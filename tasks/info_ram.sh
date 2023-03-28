#!/bin/sh
#info: Show RAM detected by OS and percentage used

# windows
if [ -n "$(command -v systeminfo)" ]; then
    DATA_RAM_INFO=$(systeminfo)
    RAM_TOTAL=$(echo "$DATA_RAM_INFO" | grep "Total Physical Memory:" |
        awk -F ':' '{print $2}' | awk '{$1=$1;print}' | tr -d ' ')
    RAM_FREE=$(echo "$DATA_RAM_INFO" | grep "Available Physical Memory:" |
        awk -F ':' '{print $2}' | awk '{$1=$1;print}' | tr -d ' ')

    RAM_TOTAL_NR="$(echo "$RAM_TOTAL" | tr -d 'MB' | tr -d 'GB' | tr -d 'TB')"
    RAM_FREE_NR="$(echo "$RAM_FREE" | tr -d 'MB' | tr -d 'GB' | tr -d 'TB')"
    RAM_USED_NR=$((RAM_TOTAL_NR - RAM_FREE_NR))

    if echo "$RAM_TOTAL" | grep -q "MB"; then
        RAM_USED="$RAM_USED_NR""MB"
    elif echo "$RAM_TOTAL" | grep -q "GB"; then
        RAM_USED="$RAM_USED_NR""GB"
    elif echo "$RAM_TOTAL" | grep -q "TB"; then
        RAM_USED="$RAM_USED_NR""TB"
    fi
# posix
else
    DATA_RAM_INFO=$(free -h)
    RAM_TOTAL=$(echo "$DATA_RAM_INFO" | grep Mem | awk '{print $2}')
    RAM_USED=$(echo "$DATA_RAM_INFO" | grep Mem | awk '{print $3}')
    RAM_FREE=$(echo "$DATA_RAM_INFO" | grep Mem | awk '{print $4}')
fi

printf '%s\t%s\t%s\n' "Total $RAM_TOTAL" "Used $RAM_USED" "Free $RAM_FREE"
