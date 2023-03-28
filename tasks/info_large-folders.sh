#!/bin/sh
#info: Find large folders on the local filesystem, WARNING: can take long!

find_folders() {
    du -x --max-depth 5 -h "$1"* 2>&1 | grep '[0-9\.]\+G' | sort -hr | head
}

# windows
if [ -n "$(command -v systeminfo)" ]; then
    if [ -d "/cygdrive" ]; then
        find_folders /cygdrive/
    else
        find_folders /
    fi
# posix
else
    find_folders /
fi
