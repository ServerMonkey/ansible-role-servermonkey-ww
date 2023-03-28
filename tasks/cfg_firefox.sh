#!/bin/sh
#info: Set Firefox defaults for first start. Disable all firstrun pop-ups
#info: , set as default browser and set homepage to duckduckgo.com

# args
HOMEPAGE="$1"
if [ -z "$HOMEPAGE" ]; then
    HOMEPAGE="http://duckduckgo.com/"
fi

# detect OS and set basic variables
# windows
if [ -n "$(command -v systeminfo)" ]; then
    HOME=$(cygpath -u "$(env | grep USERPROFILE | awk -F'=' '{print $2}')")
    PROGRAMFILES=$(cygpath -u "$(env | grep PROGRAMFILES |
        awk -F'=' '{print $2}')")
    BIN_FIREFOX="$PROGRAMFILES/Mozilla Firefox/firefox.exe"
# posix
else
    BIN_FIREFOX=$(command -v firefox)
fi

# verify
if [ -z "$HOME" ]; then
    echo "ERROR: Can not find users home path"
    exit 1
fi
if ! [ -f "$BIN_FIREFOX" ]; then
    echo "ERROR: Can not find firefox"
    exit 1
fi

findprofile() {
    find "$HOME" -name prefs.js | grep -i firefox | grep -i .default
}

# create a new profile if there is none
FILE_PREFS=$(findprofile)
if [ -z "$FILE_PREFS" ]; then
    "$BIN_FIREFOX" -CreateProfile default 1>/dev/null 2>&1
    "$BIN_FIREFOX" -silent -setDefaultBrowser
    sleep 1 # else 'CUSTOM SETTINGS' will fail
fi

FILE_PREFS=$(findprofile)
if [ -z "$FILE_PREFS" ]; then
    echo "ERROR: Can not create a firefox profile"
    exit 1
fi

# Custom user preferences
# Tested with Firefox 3.6
echo "# CUSTOM SETTINGS
user_pref(\"browser.places.importBookmarksHTML\", false);
user_pref(\"browser.rights.3.shown\", true);
user_pref(\"browser.startup.homepage\", \"$HOMEPAGE\");
user_pref(\"browser.startup.homepage_override.mstone\", \"ignore\");
" >"$FILE_PREFS"
