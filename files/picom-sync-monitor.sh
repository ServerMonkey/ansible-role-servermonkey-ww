#!/bin/sh
#info: On XFCE, sync graphics card to monitor via OpenGL backend
# based on https://wiki.archlinux.org/title/Xfwm#Video_tearing

LOG_DIR="$HOME/.local/log"
LOG_FILE="$LOG_DIR/picom-sync-monitor.log"

mkdir -p "$LOG_DIR"

{
    date
    echo "Trying to disable XFCEs compositor (should be 'false'):"
    xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>&1 || exit 1
    # check result
    xfconf-query -c xfwm4 -p /general/use_compositing
    wait
    echo "Trying to sync display via OpenGL:"
    picom --backend glx --vsync 2>&1
    if [ "$?" = "1" ]; then
        echo "Failed to render with OpenGL, trying xrender:"
        picom --backend xrender --vsync 2>&1
    fi
    if [ "$?" = "1" ]; then
        echo "Failed to render with xrender, trying hybrid:"
        picom --backend xr_glx_hybrid --vsync 2>&1
    fi
    if [ "$?" = "1" ]; then
        echo "Failed to render with hybrid, trying without vsync:"
        picom --backend xrender 2>&1
    fi
    if [ "$?" = "1" ]; then
        echo "Failed to start picom compositor"
        exit 1
    fi
} | tee "$LOG_FILE"
