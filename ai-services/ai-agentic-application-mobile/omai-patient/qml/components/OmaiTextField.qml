import QtQuick
import QtQuick.Controls
import Omai
TextField {
    id: root
    implicitHeight: 56
    font.family: Theme.family; font.pixelSize: 14 * Theme.fontScale
    color: Theme.ink; placeholderTextColor: Theme.muted
    leftPadding: 16; rightPadding: 16
    selectByMouse: true
    Accessible.name: placeholderText
    background: Rectangle { radius: Theme.smallRadius; color: Theme.surface; border.width: root.activeFocus ? 2 : 1; border.color: root.activeFocus ? Theme.teal : Theme.line }
}
