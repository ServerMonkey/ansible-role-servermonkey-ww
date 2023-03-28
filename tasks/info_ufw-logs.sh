#!/bin/sh
#info: List and parse recent UFW firewall logs and rules
#autoroot

# windows
if [ -n "$(command -v systeminfo)" ]; then
    echo "Windows is not supported" >&2
    exit 1
fi

if [ -z "$(command -v ufw)" ]; then
    echo "ufw is not installed. Install to make this script work."
    exit 1
fi

# list rules
ufw status verbose | sed '/^ *$/d'
echo ""

# only show blocked
# remove false spaces that act as seperators
RESULTS=$(cat /var/log/ufw.log /var/log/ufw.log.? |
    sed "s|\[ *|\[|g")

# get relevant data
RESULTS_PRETTY=$(echo "$RESULTS" | awk '{print $1,$2,$3,$7,$8,$13,$12}')

# make multicast more readable
echo "$RESULTS_PRETTY" | sed 's/DST=224.0.0.1 SRC=0.0.0.0/Multicast/g'
