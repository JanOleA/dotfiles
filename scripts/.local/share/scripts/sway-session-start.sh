#!/bin/sh
# Start the Sway session's systemd services (Dux etc.) on login.
#
# The systemd user instance can outlive a Sway session (quick logout/login),
# leaving sway-session.target "active" and Dux crashed or in a failed state.
# So: pass the new session's environment to systemd, start the target,
# and explicitly reset and (re)start Dux.

dbus-update-activation-environment --systemd --all
systemctl --user start sway-session.target
systemctl --user reset-failed dms.service
systemctl --user restart dms.service
