import QtQuick
import Omai
Rectangle {
    property alias text: label.text
    property bool warning: false
    implicitWidth: label.implicitWidth + 18; implicitHeight: label.implicitHeight + 10
    radius: 7; color: warning ? Theme.warningTint : Theme.tint
    OmaiText { id: label; width: parent.width - 18; anchors.centerIn: parent; size: 10; font.weight: Font.DemiBold; color: parent.warning ? Theme.warning : Theme.teal }
}
