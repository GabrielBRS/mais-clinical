import QtQuick
import QtQuick.Controls
import Omai
Button {
    id: root
    property bool secondary: false
    property bool danger: false
    property string glyph: ""
    readonly property real naturalWidth: metrics.advanceWidth + 32
    TextMetrics { id: metrics; text: root.text; font: label.font }
    implicitHeight: Math.max(52, label.implicitHeight + 28)
    implicitWidth: 160
    padding: 16
    Accessible.name: text
    background: Rectangle {
        radius: Theme.smallRadius
        color: root.danger ? Theme.warningTint : root.secondary ? Theme.surface : Theme.teal
        border.color: root.activeFocus ? Theme.teal : root.secondary ? Theme.line : "transparent"
        border.width: root.activeFocus ? 2 : 1
        opacity: root.down ? 0.75 : root.enabled ? 1 : 0.45
        Behavior on color { ColorAnimation { duration: Theme.duration } }
    }
    contentItem: OmaiText { id: label; text: root.text; size: 14; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; color: root.danger ? Theme.warning : root.secondary ? Theme.ink : Theme.dark ? "#102C2A" : "white" }
}
