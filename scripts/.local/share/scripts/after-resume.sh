#!/bin/sh
# Run after resume from suspend (from swayidle's after-resume hook).
# Waits for the given outputs to come back, then restarts Dux Shell so its bar
# and workspace widgets pick up the reconnected monitors.
#
# Usage: after-resume.sh [OUTPUT...]     e.g. after-resume.sh DP-3
# Requires: swaymsg, jq

timeout=60    # seconds to wait for monitors that are slow to wake

for o in "$@"; do
    waited=0
    until swaymsg -t get_outputs --raw |
          jq -e --arg o "$o" 'any(.[]; .name == $o and .active)' > /dev/null
    do
        [ "$waited" -ge "$timeout" ] && break
        sleep 1
        waited=$((waited + 1))
    done

    swaymsg output "$o" power off > /dev/null
    sleep 1
    swaymsg output "$o" power on > /dev/null
done

sleep 2    # let Sway finish moving workspaces back

# DMS is also the lock screen. Restarting it while locked kills the lock client,
# and Sway then paints every output solid red, so wait until the user unlocks.
while [ "$(dms ipc call lock isLocked 2>/dev/null)" = true ]; do
    sleep 1
done

systemctl --user restart dms
