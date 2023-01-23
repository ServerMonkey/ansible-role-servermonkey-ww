#!/bin/sh
#info: Reset volume to a normal level

DEFAULT_VOL="$1"

# reset volume
pactl set-sink-volume @DEFAULT_SINK@ "$DEFAULT_VOL"%
# turn on device
pactl set-sink-mute @DEFAULT_SINK@ 0

# reset mic volume
pactl set-source-volume @DEFAULT_SOURCE@ 100%
# turn on mic
pactl set-source-mute @DEFAULT_SOURCE@ 0
