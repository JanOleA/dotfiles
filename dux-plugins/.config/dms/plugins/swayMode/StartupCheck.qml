import QtQuick
import qs.Common

// Only allow the plugin to activate under Sway. Asks Sway directly instead of
// using CompositorService.isSway, which isn't set yet when plugins load at startup.
QtObject {
    function check(done) {
        Proc.runCommand("swayMode.startupCheck", ["sh", "-c", "swaymsg -q -t get_version"], (stdout, exitCode) => {
            if (exitCode === 0) {
                done(null);
                return;
            }
            done({
                title: "Sway Mode requires Sway",
                details: "This widget reads binding modes through swaymsg and only works in a Sway session."
            });
        });
    }
}
