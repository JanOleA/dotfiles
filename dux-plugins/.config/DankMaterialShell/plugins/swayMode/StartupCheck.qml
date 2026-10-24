import QtQuick
import qs.Services

// Only allow the plugin to activate under Sway.
QtObject {
    function check() {
        if (CompositorService.isSway)
            return null;
        return {
            title: "Sway Mode requires Sway",
            details: "This widget reads binding modes through swaymsg and only works in a Sway session."
        };
    }
}
