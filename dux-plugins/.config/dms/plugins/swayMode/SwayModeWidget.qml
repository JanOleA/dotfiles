import QtQuick
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string mode: "default"
    readonly property bool showFullName: pluginData.showFullName ?? false
    readonly property bool active: mode !== "" && mode !== "default"
    readonly property string label: showFullName ? mode : mode.split(":")[0].trim()

    // Collapse the whole pill (background included) while in the default mode.
    onActiveChanged: setVisibilityOverride(active)

    // StartupCheck.qml has already confirmed Sway is running. Don't check
    // CompositorService.isSway here, it may not be set yet at startup.
    Component.onCompleted: {
        setVisibilityOverride(active);
        subscribeProc.running = true;
    }

    function handleLine(line) {
        if (!line || !line.trim())
            return;
        try {
            const msg = JSON.parse(line);
            // Mode events carry "change"; get_binding_state replies carry "name".
            const name = msg.change ?? msg.name;
            if (typeof name === "string")
                root.mode = name;
        } catch (e) {
            console.warn("swayMode: could not parse swaymsg output:", line);
        }
    }

    Process {
        id: subscribeProc
        command: ["swaymsg", "-r", "-m", "-t", "subscribe", "[\"mode\"]"]
        stdout: SplitParser {
            onRead: line => root.handleLine(line)
        }
        // Once subscribed, fetch the current mode so we never miss the initial state.
        onStarted: stateProc.running = true
        onExited: (exitCode, exitStatus) => {
            console.info("swayMode: swaymsg subscription exited with code", exitCode, "- restarting");
            restartTimer.start();
        }
    }

    Process {
        id: stateProc
        command: ["swaymsg", "-r", "-t", "get_binding_state"]
        stdout: StdioCollector {
            onStreamFinished: root.handleLine(text.replace(/\s+/g, " "))
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: subscribeProc.running = true
    }

    horizontalBarPill: Component {
        StyledText {
            text: root.label
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.primary
        }
    }

    verticalBarPill: Component {
        StyledText {
            text: root.label.charAt(0).toUpperCase()
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Medium
            color: Theme.primary
        }
    }
}
