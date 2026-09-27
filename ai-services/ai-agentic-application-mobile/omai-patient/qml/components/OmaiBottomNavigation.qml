import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Omai
Rectangle {
    id: root
    property string current: "home"
    signal selected(string route)
    implicitHeight: 84; color: Theme.surface
    Rectangle { height: 1; width: parent.width; color: Theme.line }
    RowLayout {
        anchors.fill: parent; anchors.margins: 6; spacing: 0
        Repeater {
            model: [{label:"Início",icon:"home",route:"home"},{label:"Histórico",icon:"clock",route:"history"},{label:"OMAI",icon:"spark",route:"chat"},{label:"Documentos",icon:"document",route:"documents"},{label:"Perfil",icon:"user",route:"profile"}]
            Button {
                required property var modelData
                Layout.fillWidth: true; Layout.fillHeight: true
                Accessible.name: modelData.label
                onClicked: root.selected(modelData.route)
                background: Rectangle { radius: 14; color: parent.activeFocus ? Theme.tint : "transparent" }
                contentItem: Column {
                    spacing: 5
                    Rectangle {
                        width: 44; height: 36; radius: 13; anchors.horizontalCenter: parent.horizontalCenter
                        color: modelData.route === "chat" ? Theme.teal : root.current === modelData.route ? Theme.tint : "transparent"
                        OmaiIcon { anchors.centerIn: parent; width: 21; height: 21; name: modelData.icon; color: modelData.route === "chat" ? (Theme.dark ? "#102C2A" : "white") : root.current === modelData.route ? Theme.teal : Theme.muted }
                    }
                    OmaiText { text: modelData.label; size: 10; anchors.horizontalCenter: parent.horizontalCenter; color: root.current === modelData.route ? Theme.teal : Theme.muted; font.weight: Font.DemiBold }
                }
            }
        }
    }
}
