#!/usr/bin/env bash
# Switch to the lowest-numbered workspace that isn't currently in use.
# E.g. with workspaces 1, 2, 3, 5 open -> goes to 4; with 1-5 open -> goes to 6.
# Requires: jq

set -euo pipefail

# Numbers of all existing workspaces (non-numeric workspace names have num = -1)
used=$(swaymsg -t get_workspaces --raw | jq -r '.[].num | select(. > 0)')

n=1
while grep -qx "$n" <<< "$used"; do
    n=$((n + 1))
done

swaymsg workspace number "$n" > /dev/null
