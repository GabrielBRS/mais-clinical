import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Omai
Button {
    id: root
    property var record: ({})
    signal activated(var record)
    implicitHeight: content.implicitHeight + 36
    padding: 18
    Accessible.name: (record.title || "") + ". " + (record.subtitle || "")
    onClicked: activated(record)
    background: OmaiCard { color: root.down ? Theme.tint : Theme.surface; border.color: root.activeFocus ? Theme.teal : Theme.line }
    contentItem: RowLayout {
        id: content
        spacing: 14
        Rectangle {
            Layout.alignment: Qt.AlignTop
            width: 44; height: 44; radius: 14; color: Theme.tint
            OmaiIcon { anchors.centerIn: parent; name: root.record.icon || "document"; width: 22; height: 22 }
        }
        ColumnLayout {
            Layout.fillWidth: true; spacing: 6
            OmaiText { text: root.record.title || ""; font.weight: Font.DemiBold; Layout.fillWidth: true }
            OmaiText { text: root.record.subtitle || ""; size: 12; color: Theme.muted; Layout.fillWidth: true }
            OmaiStatusBadge { visible: !!root.record.badge; text: root.record.badge || ""; Layout.topMargin: 3; Layout.maximumWidth: parent.width }
        }
        OmaiIcon { visible: !!root.record.route || !!root.record.action; name: "chevron"; color: Theme.muted; width: 16; height: 16 }
    }
}
