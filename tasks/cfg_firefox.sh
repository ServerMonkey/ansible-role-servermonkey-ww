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

process_has_stopped() {
    local PIDS
    for counter in $(seq 10); do
        PIDS=$(find_pids "$1")
        if [ -z "$PIDS" ]; then
            break
        fi
        sleep 1
        if [ "$counter" = 10 ]; then
            echo "process is still running PIDS:$PIDS"
            return 1
        fi
    done
}

process_quit() {
    local PIDS
    local FOUND
    local KILL_METHOD="$2"
    local KILL_SIGNAL

    if [ "$KILL_METHOD" = "soft" ]; then
        KILL_SIGNAL=9
    elif [ "$KILL_METHOD" = "hard" ]; then
        KILL_SIGNAL=15
    fi

    # wait for process to start
    sleep 1

    # find a running process
    PIDS=$(find_pids "$1")
    # kill all processes
    if [ -n "$PIDS" ]; then
        if [ "$OS" = windows ]; then
            for SUBPID in $PIDS; do
                FOUND=$(ps -p "$SUBPID" -o comm=)
                echo "quit process PID:$SUBPID NAME:$1 CMD:$FOUND"
                taskkill "/PID" "$SUBPID" "/F" 1>/dev/null 2>&1 ||
                    echo "FAILED: taskkill /PID $SUBPID /F"
            done
        else
            for SUBPID in $PIDS; do
                FOUND=$(ps -p "$SUBPID" -o comm=)
                echo "$KILL_METHOD quit process PID:$SUBPID NAME:$1 CMD:$FOUND"
                kill -"$KILL_SIGNAL" "$SUBPID" ||
                    echo "skip $KILL_METHOD quit: $SUBPID"
                if [ "$KILL_METHOD" = "hard" ]; then
                    process_has_stopped "$1" || error "hard kill failed"
                else
                    process_has_stopped "$1"
                fi
            done
        fi
    else
        echo "process already quit: $1"
    fi
}

# create a new profile if there is none
FILE_PREFS=$(findprofile)
if [ -z "$FILE_PREFS" ]; then
    if [ "$OS" = windows ]; then
        "$BIN_FIREFOX" -headless -CreateProfile default 1>/dev/null 2>&1
        process_has_stopped "firefox.exe" || process_quit "firefox.exe"
        process_has_stopped "firefox.exe" || exit 1
        "$BIN_FIREFOX" -headless -silent -setDefaultBrowser 1>/dev/null 2>&1
        process_has_stopped "firefox.exe" || process_quit "firefox.exe"
        process_has_stopped "firefox.exe" || exit 1
    else
        PROCESS_A="headless -url localhost"
        "$BIN_FIREFOX" -headless -url localhost 1>/dev/null 2>&1 &
        sleep 2
        process_quit "$PROCESS_A" "soft"
        PROCESS_A_PIDS=$(find_pids "$PROCESS_A")
        if [ -n "$PROCESS_A_PIDS" ]; then
            echo "firefox is still running, forcing process termination"
            sleep 4
            process_quit "$PROCESS_A" "hard" || exit 1
        fi

        PROCESS_B="headless -silent -setDefaultBrowser"
        "$BIN_FIREFOX" -headless -silent -setDefaultBrowser 1>/dev/null 2>&1 &
        sleep 2
        process_quit "$PROCESS_B" "soft"
        PROCESS_B_PIDS=$(find_pids "$PROCESS_B")
        if [ -n "$PROCESS_B_PIDS" ]; then
            echo "firefox is still running, forcing process termination"
            sleep 4
            process_quit "$PROCESS_B" "hard" || exit 1
        fi
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
