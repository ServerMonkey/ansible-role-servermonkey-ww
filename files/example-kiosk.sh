#!/bin/sh
#info: Start kiosk application and visit localhost or example.com

# change resolution if this is a VM, good for testing
SYSTEM_IS_VM=$(hostnamectl status | grep Virt)
if [ -n "${SYSTEM_IS_VM}" ]; then
    xrandr -s 1280x720
fi

# determin website
if [ -d /var/www/html ]; then
    URL="http://localhost/"
else
    URL="http://example.com/"
fi

# example
if command -v simple-kiosk; then
    simple-kiosk "$URL"
else
    chromium "$URL" \
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
fi

# wait for os tasks to load
sleep 3
