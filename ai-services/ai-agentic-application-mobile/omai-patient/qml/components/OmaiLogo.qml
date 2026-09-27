import QtQuick
import Omai
Item {
    id: root
    property color color: Theme.teal
    implicitWidth: 52; implicitHeight: 52
    Repeater {
        model: 4
        Rectangle {
            required property int index
            width: root.width * 0.40; height: root.height * 0.70
            radius: width / 2; color: "transparent"; border.color: root.color; border.width: root.width * 0.045
            x: (root.width - width) / 2; y: (root.height - height) / 2
            rotation: index * 45
        }
    }
    Rectangle { width: root.width * 0.14; height: width; radius: width / 2; color: root.color; anchors.centerIn: parent }
}
