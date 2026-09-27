import QtQuick
import QtQuick.Layouts
import Omai
RowLayout {
    property string text: "Seus dados, sob seu controle"
    spacing: 7
    OmaiIcon { name: "shield"; implicitWidth: 14; implicitHeight: 14 }
    OmaiText { text: parent.text; size: 11; color: Theme.muted; Layout.fillWidth: true }
}
