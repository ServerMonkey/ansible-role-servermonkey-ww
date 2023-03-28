#!/bin/sh
#info: Disable Screen Saver

# must run as build in admin
if [ -n "$(command -v systeminfo)" ]; then
    if [ "$(id -u 544)" -ne 544 ]; then
        echo 'This script must be run as admin!' >&2
        exit 1
    fi
else
    exit 0
fi

# XP
regtool set "\HKEY_CURRENT_USER\Control Panel\Desktop\ScreenSaveActive" -s "0"

# Windows 7, Windows 8, and Windows 10
# https://www.tenforums.com/tutorials/118541-enable-disable-screen-saver-windows.html
#regtool set "\HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Control Panel\Desktop\ScreenSaveActive" -s "0"
#regtool set "\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop\ScreenSaveActive" -s "0"
