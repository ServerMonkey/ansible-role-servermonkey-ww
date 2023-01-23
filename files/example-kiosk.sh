#!/bin/sh
#info: Start Chromium in kiosk mode and visit example.com

# change resolution if this is a VM, good for testing
SYSTEM_IS_VM=$(hostnamectl status | grep Virt)
if [ -n "${SYSTEM_IS_VM}" ]; then
    xrandr -s 1280x720
fi

# example
sleep 3  # wait for os tasks to load
chromium http://example.com/ \
    --window-size=1920,1080 \
    --start-fullscreen \
    --kiosk \
    --incognito \
    --noerrdialogs \
    --disable-translate \
    --no-first-run \
    --fast \
    --fast-start \
    --disable-infobars \
    --disable-features=TranslateUI \
    --disk-cache-dir=/dev/null \
    --password-store=basic
