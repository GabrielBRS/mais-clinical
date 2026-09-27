import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Omai
Dialog {
    id: root
    property string message: ""
    property string confirmText: "Confirmar"
    signal confirmed()
    modal: true; anchors.centerIn: parent; width: Math.min(parent.width - 40, 380)
    padding: 24
    background: OmaiCard { }
    header: OmaiText { text: root.title; size: 20; font.weight: Font.DemiBold; padding: 24; bottomPadding: 0 }
    contentItem: ColumnLayout {
        spacing: 16
        OmaiText { text: root.message; color: Theme.muted; Layout.fillWidth: true }
        OmaiButton { text: root.confirmText; Layout.fillWidth: true; onClicked: { root.confirmed(); root.close() } }
        OmaiButton { text: "Voltar"; secondary: true; Layout.fillWidth: true; onClicked: root.close() }
    }
}
