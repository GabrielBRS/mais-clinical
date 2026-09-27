import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Omai
Item {
    id: root
    ColumnLayout {
        anchors.fill: parent; spacing: 0
        Rectangle {
            Layout.fillWidth: true; implicitHeight: info.implicitHeight + 20; color: Theme.tint
            OmaiText { id: info; x: 24; y: 10; width: parent.width - 48; text: "IA para organizar seu cuidado. Não substitui uma avaliação médica. Roteiro demonstrativo."; size: 11; color: Theme.teal }
        }
        ListView {
            id: conversation; Layout.fillHeight: true; Layout.fillWidth: true; clip: true; spacing: 18
            topMargin: 22; bottomMargin: 20; model: patient.messages
            onCountChanged: Qt.callLater(function() { conversation.positionViewAtEnd() })
            delegate: Item {
                required property var modelData
                width: conversation.width; height: messageColumn.implicitHeight
                Column {
                id: messageColumn; x: 24; width: parent.width - 48; spacing: 8
                Row { visible: modelData.role === "assistant"; spacing: 7; OmaiLogo { width: 20; height: 20 } OmaiText { text: "OMAI"; size: 10; font.bold: true; color: Theme.teal; topPadding: 3 } }
                OmaiChatBubble { width: parent.width * (modelData.role === "user" ? 0.88 : 1); anchors.right: parent.right; message: modelData.text; outgoing: modelData.role === "user" }
                }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true; Layout.margins: 16; spacing: 10
            OmaiButton { visible: patient.state.urgent; Layout.fillWidth: true; text: "Procure atendimento médico imediato"; danger: true; onClicked: patient.navigate("urgent") }
            OmaiCard {
                visible: patient.state.step >= 4 && !patient.state.urgent; Layout.fillWidth: true; implicitHeight: summary.implicitHeight + 24; color: Theme.tint
                Column { id: summary; x: 12; y: 12; width: parent.width - 24; spacing: 6
                    OmaiText { text: "Sintomas identificados"; font.bold: true }
                    OmaiText { text: patient.state.location + " · " + patient.state.duration + " · " + patient.state.intensity + "/10"; size: 12; width: parent.width }
                }
            }
            Flow { Layout.fillWidth: true; spacing: 6
                Repeater { model: patient.suggestions
                    OmaiButton { required property string modelData; text: modelData; secondary: true; implicitWidth: Theme.fontScale > 1.1 ? root.width - 32 : Math.min(root.width - 32, naturalWidth + 24); onClicked: patient.send(modelData) }
                }
            }
            RowLayout { Layout.fillWidth: true; spacing: 8
                OmaiButton { text: "+"; implicitWidth: 44; Accessible.name: "Anexar documento de exemplo"; secondary: true; onClicked: attachment.open() }
                OmaiTextField { id: input; Layout.fillWidth: true; placeholderText: "Escreva sua mensagem…"; maximumLength: 2000; onAccepted: { patient.send(text); text = "" } }
                OmaiButton { text: "↑"; implicitWidth: 44; Accessible.name: "Enviar mensagem"; onClicked: { patient.send(input.text); input.clear() } }
            }
            RowLayout { Layout.fillWidth: true
                OmaiText { text: "SOMENTE DEMONSTRAÇÃO"; size: 9; color: Theme.muted; Layout.fillWidth: true }
                Button { text: "Nova conversa"; flat: true; implicitHeight: 32; onClicked: patient.act("restart") }
            }
        }
    }
    OmaiModal { id: attachment; title: "Adicionar à conversa"; message: "Anexe o hemograma de exemplo para demonstrar o envio de exames e documentos. Voz e imagens estarão disponíveis futuramente."; confirmText: "Anexar exame de exemplo"; onConfirmed: patient.act("attach") }
}
