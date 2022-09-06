#!/bin/sh
#info: Find CPU intense processes

sleep 3
ps -eo pcpu,pid,user,args --no-headers | sort -t. -nk1,2 -k4,4 -r | head -n 5 |
    sed -e '/mitogen:/d' \
        -e '/^ 0./d' \
        -e '/^ 1./d' \
        -e '/^ 2./d'
