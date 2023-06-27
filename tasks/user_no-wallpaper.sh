#!/bin/sh
#info: Removes/blanks the wallpaper for the current user

# windows
if [ -n "$(command -v systeminfo)" ]; then
    # can be run as any user
    OS=$(systeminfo | grep "OS Name:" | awk -F ':' '{print $2}' |
        awk '{$1=$1;print}')
    if echo "$OS" | grep -q "Windows"; then
        regtool set "\HKCU\Control Panel\Desktop\Wallpaper" ""
        # this needs restart
    # unknown
    else
        echo "OS not supported"
    fi
# posix
else
    # must run as normal user
    if [ "$(id -u)" = 0 ]; then
        echo 'This script must be run as a normal user, not root!' >&2
        exit 1
    fi
    if lsb_release -d | grep -o "Raspbian"; then
        # remove wallpaper for current user
        DESKTOP_CFG="$HOME/.config/pcmanfm/LXDE-pi/desktop-items-0.conf"
        HAS_WALLPAPER=$(grep "wallpaper=" "$DESKTOP_CFG")
        # wallaper is not there
        if [ -z "${HAS_WALLPAPER}" ]; then
            # making new desktop config
            touch "$DESKTOP_CFG"
            echo "wallpaper=" >>"$DESKTOP_CFG"
        # wallaper is already there
        else
            sed -i "/wallpaper=/c\wallpaper=" "$DESKTOP_CFG"
        fi
    else
        echo "OS not supported"
    fi
fi
