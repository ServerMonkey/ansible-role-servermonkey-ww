#!/bin/sh
#info: Set Firefox defaults for first start. Disable all firstrun pop-ups
#info: , set as default browser and set homepage to duckduckgo.com
# shellcheck disable=SC2009
# shellcheck disable=SC2039

# args
HOMEPAGE="$1"
if [ -z "$HOMEPAGE" ]; then
    HOMEPAGE="http://duckduckgo.com/"
fi

# detect OS and set basic variables
# windows
if [ -n "$(command -v systeminfo)" ]; then
    NEW_HOME=$(cygpath -u "$(env | grep USERPROFILE | awk -F'=' '{print $2}')")
    PROGRAMFILES=$(cygpath -u "$(env | grep PROGRAMFILES |
        awk -F'=' '{print $2}')")
    BIN_FIREFOX="$PROGRAMFILES/Mozilla Firefox/firefox.exe"
    OS=windows
# posix
else
    # must run as normal user
    if [ "$(id -u)" = 0 ]; then
        echo 'This script must be run as a normal user, not root!' >&2
        exit 1
    fi
    NEW_HOME="$HOME"
    BIN_FIREFOX=$(command -v firefox)
    OS=posix
fi

# verify
if [ -z "$NEW_HOME" ]; then
    echo "ERROR: Can not find users home path"
    exit 1
fi
if ! [ -f "$BIN_FIREFOX" ]; then
    echo "ERROR: Can not find firefox"
    exit 1
fi

error() {
    echo "ERROR: $1"
    exit 1
}

findprofile() {
    find "$NEW_HOME" -name prefs.js | grep -i firefox | grep -i .default
}

find_pids() {
    local PIDS
    if [ "$OS" = windows ]; then
        PIDS=$(ps -Ws | grep -F "$1" | awk '{print $1}')
    else
        PIDS=$(ps aux | grep -v grep | grep -F "$1" | awk '{print $2}')
    fi
    echo "$PIDS"
}

process_wait() {
    local PIDS
    for counter in $(seq 10); do
        PIDS=$(find_pids "$1")
        if [ -z "$PIDS" ]; then
            break
        fi
        sleep 1
        if [ "$counter" = 10 ]; then
            echo "timeout, waiting for process to quit PIDS:$PIDS"
            exit 1
        fi
    done
}

process_quit() {
    local PIDS
    local FOUND

    # wait for process to start
    sleep 1

    # find a running process
    PIDS=$(find_pids "$1")
    if [ -n "$PIDS" ]; then
        # kill that process
        if [ "$OS" = windows ]; then
            for SUBPID in $PIDS; do
                FOUND=$(ps -p "$SUBPID" -o comm=)
                echo "quit process PID:$SUBPID NAME:$1 FOUND:$FOUND"
                taskkill "/PID" "$SUBPID" "/F" 1>/dev/null 2>&1 ||
                    echo "FAILED: taskkill /PID $SUBPID /F"
            done
        else
            # soft
            for SUBPID in $PIDS; do
                FOUND=$(ps -p "$SUBPID" -o comm=)
                echo "quit process PID:$SUBPID NAME:$1 FOUND:$FOUND"
                kill -15 "$SUBPID" || echo "FAILED: kill -15 '$SUBPID"
                process_wait "$1"
            done
        fi

        # check that is has quit
        process_wait "$1" || error "process_wait $1"
    fi
}

# create a new profile if there is none
FILE_PREFS=$(findprofile)
if [ -z "$FILE_PREFS" ]; then
    if [ "$OS" = windows ]; then
        "$BIN_FIREFOX" -headless -CreateProfile default 1>/dev/null 2>&1
        process_wait "firefox.exe"
        process_quit "firefox.exe"
        "$BIN_FIREFOX" -headless -silent -setDefaultBrowser 1>/dev/null 2>&1
        process_wait "firefox.exe"
        process_quit "firefox.exe"
    else
        "$BIN_FIREFOX" -headless -url localhost 1>/dev/null 2>&1 &
        process_quit "headless -url localhost"
        "$BIN_FIREFOX" -headless -silent -setDefaultBrowser 1>/dev/null 2>&1 &
        process_quit "headless -silent -setDefaultBrowser"
    fi
fi

FILE_PREFS=$(findprofile)
if [ -z "$FILE_PREFS" ]; then
    error "Failed to create a firefox profile"
fi

# Custom user preferences
echo "# CUSTOM SETTINGS
user_pref(\"browser.places.importBookmarksHTML\", false);
user_pref(\"browser.rights.3.shown\", true);
user_pref(\"browser.startup.homepage\", \"$HOMEPAGE\");
user_pref(\"browser.startup.homepage_override.mstone\", \"ignore\");
" >"$FILE_PREFS"
