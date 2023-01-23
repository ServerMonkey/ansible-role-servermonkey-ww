#!/bin/sh
#info: List and parse recent UFW firewall logs and rules
#autoroot

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
