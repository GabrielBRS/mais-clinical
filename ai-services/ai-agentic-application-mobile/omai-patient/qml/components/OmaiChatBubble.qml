import QtQuick
import Omai
Rectangle {
    id: root
    property string message: ""
    property bool outgoing: false
    implicitHeight: body.implicitHeight + 30
    radius: 20; color: outgoing ? Theme.teal : Theme.surface
    border.color: outgoing ? "transparent" : Theme.line
    OmaiText { id: body; x: 16; y: 15; width: parent.width - 32; text: root.message; size: 14; color: root.outgoing ? (Theme.dark ? "#102C2A" : "white") : Theme.ink }
}
