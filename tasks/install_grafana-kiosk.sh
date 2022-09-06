#!/bin/sh
#info: Download grafana-kiosk for the current hardware to /opt/grafana-kiosk
#autoroot
# https://github.com/grafana/grafana-kiosk

HARDWARE=$(uname -m)

PRE="https://github.com/grafana/grafana-kiosk/releases/download/v"
VER="1.0.4"
SUF="/grafana-kiosk.linux."
DEST="/opt/grafana-kiosk"

# set correct URL based on hardware
case $HARDWARE in
x86_64)
    CPU=amd64
    ;;
armv6?)
    CPU=armv6
    ;;
armv7?)
    CPU=armv7
    ;;
aarch64)
    CPU=arm64
    ;;
*)
    echo "CPU architecture $HARDWARE not supported, update this script."
    exit 1
    ;;
esac

# download if not already present
if [ ! -f "$DEST" ]; then
    wget -q -O "$DEST" "$PRE$VER$SUF$CPU" ||
        (
            echo "Error: Cant't download grafana-kiosk"
            exit 1
        )
    chmod +x "$DEST" || exit 1
fi
