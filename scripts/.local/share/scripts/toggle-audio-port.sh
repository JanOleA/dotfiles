#!/bin/sh
# Toggle the motherboard's analog output between the rear line-out (speakers)
# and the front headphone jack, and show which one is active.
#
# By default it uses the first analog sink it finds; set ANALOG_SINK to a sink
# name (see `pactl list short sinks`) to pick a specific one.
# Requires: pactl (libpulse), jq; uses Dux for the on-screen message if running.

speakers=analog-output-lineout
headphones=analog-output-headphones

sinks=$(pactl -f json list sinks) || exit 1

if [ -n "$ANALOG_SINK" ]; then
    sink=$ANALOG_SINK
else
    sink=$(printf '%s' "$sinks" | jq -r '[.[] | select(.name | test("analog-stereo"))][0].name // empty')
fi

if [ -z "$sink" ]; then
    echo "toggle-audio-port: no analog sink found" >&2
    exit 1
fi

active=$(printf '%s' "$sinks" | jq -r --arg s "$sink" '.[] | select(.name == $s) | .active_port')

if [ "$active" = "$headphones" ]; then
    new=$speakers;   label="Speakers"
else
    new=$headphones; label="Headphones"
fi

pactl set-sink-port "$sink" "$new" || exit 1

dms ipc call toast info "Audio output: $label" > /dev/null 2>&1 || echo "Audio output: $label"
