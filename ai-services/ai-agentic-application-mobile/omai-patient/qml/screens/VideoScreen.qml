import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Omai
Rectangle {
    color: "#142D32"
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 20
        RowLayout { Layout.fillWidth: true
            OmaiLogo { width: 28; height: 28; color: "#9ADDD0" }
            OmaiText { text: "OMAI · Teleconsulta"; color: "white"; Layout.fillWidth: true }
            OmaiStatusBadge { text: "SIMULAÇÃO" }
        }
        Rectangle {
            Layout.fillHeight: true; Layout.fillWidth: true; radius: 30; color: "#24454A"
            Column { anchors.centerIn: parent; width: parent.width - 40; spacing: 18
                Rectangle { width: 110; height: 110; radius: 55; color: "#355D60"; anchors.horizontalCenter: parent.horizontalCenter; OmaiText { text: "JS"; size: 38; color: "#B6E8DE"; anchors.centerIn: parent } }
                OmaiText { text: "Dr. João Silva"; size: 24; color: "white"; width: parent.width; horizontalAlignment: Text.AlignHCenter }
                OmaiText { text: "Cardiologia\nVídeo demonstrativo · Sem conexão real"; size: 12; color: "#AEC6C8"; width: parent.width; horizontalAlignment: Text.AlignHCenter }
            }
            Rectangle { width: 92; height: 124; radius: 20; color: "#3D6467"; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 14
                Column { anchors.centerIn: parent; spacing: 8; OmaiIcon { anchors.horizontalCenter: parent.horizontalCenter; name: patient.state.camera ? "user" : "close"; color: "#C6ECE5" } OmaiText { text: "Você · Demo"; size: 10; color: "white" } }
            }
        }
        OmaiDocumentCard { Layout.fillWidth: true; record: ({title:"Documento compartilhado",subtitle:"Prescrição digital · Dr. João Silva",icon:"document",route:"prescription"}); onActivated: patient.navigate("prescription") }
        RowLayout { Layout.fillWidth: true; spacing: 8
            Repeater { model: [{label:patient.state.mic ? "Mic ligado" : "Mic mudo",icon:"mic",action:"mic"},{label:patient.state.camera ? "Câmera on" : "Câmera off",icon:"video",action:"camera"},{label:patient.state.speaker ? "Som ligado" : "Som mudo",icon:"sound",action:"speaker"}]
                Button { required property var modelData; Layout.fillWidth: true; implicitHeight: 72; Accessible.name: modelData.label; onClicked: patient.act(modelData.action)
                    background: Rectangle { radius: 20; color: "#2D4D52"; border.color: parent.activeFocus ? "white" : "transparent" }
                    contentItem: Column { spacing: 8; OmaiIcon { anchors.horizontalCenter: parent.horizontalCenter; name: modelData.icon; color: "white" } OmaiText { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label; size: 10; color: "white" } }
                }
            }
        }
        OmaiButton { text: "Chat da consulta"; secondary: true; Layout.fillWidth: true; onClicked: callChat.open() }
        OmaiButton { text: "Encerrar chamada"; danger: true; Layout.fillWidth: true; onClicked: patient.act("end-call") }
    }
    OmaiModal { id: callChat; title: "Chat da consulta"; message: "Dr. João Silva: Sua prescrição demonstrativa está disponível nos documentos compartilhados."; confirmText: "Ver prescrição"; onConfirmed: patient.navigate("prescription") }
}
