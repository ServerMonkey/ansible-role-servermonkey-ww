#!/bin/sh
#info: Show system uptime (cygwin comp)

# windows
if [ -n "$(command -v systeminfo)" ]; then
    systeminfo | grep "System Up Time:" | awk -F ':' '{print $2}' |
        awk '{$1=$1;print}'
# posix
else
    uptime -p
fi
