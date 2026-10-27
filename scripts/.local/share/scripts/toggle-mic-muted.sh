#!/bin/sh
# Toggle the microphone mute status
# Requires: pactl; uses Dux for the on-screen message if running.

pactl set-source-mute @DEFAULT_SOURCE@ toggle || exit 1

if LC_ALL=C pactl get-source-mute @DEFAULT_SOURCE@ | grep -q 'yes'; then
    mic_status="Mic is muted"
else
    mic_status="Mic is live"
fi

dms ipc call toast info "$mic_status" > /dev/null 2>&1 || echo "$mic_status"