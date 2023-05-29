#!/bin/sh
#info: Show network configuration (cygwin comp)
#autoroot

# windows
if [ -n "$(command -v systeminfo)" ]; then
	systeminfo |
		grep -A 9999 "NetWork Card" |
		sed '/NetWork Card/d' |
		sed '/IP address(es)/d' |
		awk '{$1=$1;print}'

	# list network services
	echo "service ports:"
	netstat -ano |
		sed '/Active Connections/d' |
		grep -e LISTENING -e ESTABLISHED |
		sed '/^ *$/d' |
		sed 's/^  //g'

# posix
else
	ip -br a | sed "/^lo.*/d"
	if [ -f "/etc/resolv.conf" ]; then
		grep "nameserver" /etc/resolv.conf
	else
		echo "nameserver unset"
	fi

	# list network services
	TMP_FILE=$(mktemp)
	{
		echo "[TCPv4-ports]"
		ss -tlpn4
		echo "[UDPv4-ports]"
		ss -ulpn4
		echo "[TCPv6-ports]"
		ss -tlpn6
		echo "[UDPv6-ports]"
		ss -ulpn6
	} | sed "s/Local Address/LocalAddress/g" |
		sed "s/Peer Address/PeerAddress/g" |
		sed 's/PortProcess/Port Process PID FD/g' |
		sed 's/users://g' |
		sed 's/pid=//g' |
		sed 's/fd=//g' |
		sed "s/,/ /g" |
		sed 's/((//g' |
		sed 's/))//g' >>"$TMP_FILE"
	awk '{$2=$3=$8=""; print $0}' "$TMP_FILE" | column -t
	rm "$TMP_FILE"
fi
