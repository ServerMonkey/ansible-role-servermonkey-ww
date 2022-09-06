#!/bin/sh
#info: Removes/blanks the wallpaper on Raspbian Desktop

# must run as normal user
if [ "$(id -u)" = 0 ]; then
    echo 'This script must be run as a normal user, not root!' >&2
    exit 1
fi

# do on Raspbian
OS=$(lsb_release -d | grep -o "Raspbian")
if [ -n "${OS}" ]; then

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
