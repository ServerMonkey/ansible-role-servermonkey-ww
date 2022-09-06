#!/bin/sh
#info: Remove Linux logfiles, users cache, history from BASH, ZSH and Firefox
#autoroot

# must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run as root!' >&2
    exit 1
fi

# remove old log files
# shellcheck disable=SC2044
for CLEAN in $(find /var/log/ -type f); do cp /dev/null "$CLEAN"; done
find /var/log -type f -regex ".*\.gz$" -delete
find /var/log -type f -regex ".*\.[0-9]$" -delete

# remove files for all normal users
USERS="/home/*"
for i in $USERS; do
    # remove bash history for all users
    rm -f "$i"/.bash_history
    rm -f "$i"/.zsh_history
    # generic cache
    rm -rf "$i"/.cache
    # firefox
    rm -rf "$i"/.mozilla/firefox/*.default/*.sqlite
    rm -rf "$i"/.mozilla/firefox/*.default/sessionstore.js
    rm -rf "$i"/.mozilla/firefox/*.default-esr/*.sqlite
    rm -rf "$i"/.mozilla/firefox/*.default-esr/sessionstore.js
done

# remove files for root
rm -f /root/.bash_history
rm -f /root/.zsh_history
rm -rf /root/.cache

# extra clean up BASH history
echo "history -cw" >/tmp/clearhistory
bash /tmp/clearhistory
rm -f /tmp/clearhistory
