import QtQuick
import qs.Common
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "swayMode"

    ToggleSetting {
        settingKey: "showFullName"
        label: "Show full mode name"
        description: "Show the whole mode name instead of only the part before the first \":\""
        defaultValue: false
    }
}
