#!/bin/sh
#info: Show network configuration (cygwin comp)

# windows
if [ -n "$(command -v systeminfo)" ]; then
    systeminfo |
        grep -A 9999 "NetWork Card" |
        sed '/NetWork Card/d' |
        sed '/IP address(es)/d' |
        awk '{$1=$1;print}'
    # list services
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
    # list services
    echo "service ports:"
    ss -tulpn | grep LISTEN | sed 's/ *$//'
fi
