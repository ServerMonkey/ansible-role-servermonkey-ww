#!/bin/sh
#info: Find CPU intense processes
#autoroot

# windows
if [ -n "$(command -v systeminfo)" ]; then
    # must run as build in admin
    if [ "$(id -u 544)" -ne 544 ]; then
        echo 'This script must be run as admin!' >&2
        exit 1
    fi
    echo "Windows is not supported" >&2
    exit 1
# posix
else
    # must run as root
    if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run as root!' >&2
        exit 1
    fi
    sleep 3
    ps -eo pcpu,pid,user,args --no-headers | sort -t. -nk1,2 -k4,4 -r | head -n 5 |
        sed -e '/mitogen:/d' \
            -e '/^ 0./d' \
            -e '/^ 1./d' \
            -e '/^ 2./d'
fi
