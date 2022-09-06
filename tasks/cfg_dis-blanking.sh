#!/bin/sh
#info: Stop the screen from turning off on Raspbian Desktop, useful for kiosk

# must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

# do on Raspbian
OS=$(lsb_release -d | grep -o "Raspbian")
if [ -n "${OS}" ]; then

    # disable screen from going blank/dark
    LXDE_CFG="/etc/xdg/lxsession/LXDE-pi/autostart"
    # remove old config
    sed -i \
        -e '/xset s noblank/d' \
        -e '/xset s off/d' \
        -e '/xset -dpms/d' \
        $LXDE_CFG
    # add new config
    printf %s"\n" \
        "@xset s noblank" \
        "@xset s off" \
        "@xset -dpms" \
        >>$LXDE_CFG

    # disable text terminals from going blank/dark
    LBD_CFG="/etc/kbd/config"
    mkdir -p "/etc/kbd"
    touch $LBD_CFG
    # remove old config
    sed -i \
        -e '/BLANK_TIME/d' \
        -e '/POWERDOWN_TIME/d' \
        $LBD_CFG
    # add new config
    printf %s"\n" \
        "BLANK_TIME=0" \
        "POWERDOWN_TIME=0" \
        >>$LBD_CFG
else
    echo "OS not supported"
    exit 1
fi
