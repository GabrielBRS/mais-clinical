import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Omai
OmaiPage {
    OmaiText { text: "SÁBADO, 26 DE SETEMBRO"; size: 10; font.letterSpacing: 1.4; color: Theme.muted }
    Column { width: parent.width; spacing: 5
        OmaiText { text: "Bom dia, Gabriel"; size: 30; font.weight: Font.DemiBold; width: parent.width }
        OmaiText { text: "Como você está hoje?"; size: 16; color: Theme.muted }
    }
    OmaiCard {
        width: parent.width; height: hero.implicitHeight + 40
        gradient: Gradient { GradientStop { position: 0; color: Theme.dark ? "#233E42" : "#E0F3ED" } GradientStop { position: 1; color: Theme.dark ? "#253740" : "#E8F2F7" } }
        border.color: Theme.dark ? Theme.line : "#D6E9E4"
        Column {
            id: hero; x: 20; y: 20; width: parent.width - 40; spacing: 15
            RowLayout { width: parent.width; OmaiLogo { width: 38; height: 38 } Item { Layout.fillWidth: true } OmaiStatusBadge { text: "SEU ESPAÇO DE CUIDADO" } }
            OmaiText { text: "Vamos conversar?"; size: 25; font.weight: Font.DemiBold; width: parent.width }
            OmaiText { text: "Converse com a OMAI. Organize seus sintomas e encontre o próximo passo."; size: 13; color: Theme.muted; width: parent.width }
            OmaiTextField { id: feeling; width: parent.width; placeholderText: "Como você está se sentindo?"; onAccepted: { patient.navigate("chat"); if (text.trim()) patient.send(text) } }
            OmaiButton { width: parent.width; text: "Conversar com a OMAI  ↗"; onClicked: { const value = feeling.text; patient.navigate("chat"); if (value.trim()) patient.send(value) } }
        }
    }
    RowLayout { width: parent.width; OmaiSection { text: "Seu cuidado, à mão"; Layout.fillWidth: true } OmaiText { text: "ACESSO RÁPIDO"; size: 9; color: Theme.muted; font.letterSpacing: 1 } }
    RowLayout {
        width: parent.width; spacing: 8
        Repeater {
            model: [{title:"Consultas",icon:"calendar",route:"consultations"},{title:"Histórico",icon:"clock",route:"history"},{title:"Receitas",icon:"document",route:"prescriptions"},{title:"Exames",icon:"flask",route:"exams"},{title:"Remédios",icon:"pill",route:"medications"}]
            Button {
                required property var modelData
                Layout.fillWidth: true; Layout.preferredWidth: 1; implicitHeight: 82
                Accessible.name: modelData.title; onClicked: patient.navigate(modelData.route)
                background: Rectangle { radius: 18; color: parent.down ? Theme.tint : Theme.surface; border.color: parent.activeFocus ? Theme.teal : Theme.line }
                contentItem: Column { spacing: 10; OmaiIcon { anchors.horizontalCenter: parent.horizontalCenter; name: modelData.icon; width: 23; height: 23 } OmaiText { text: modelData.title; size: 9; anchors.horizontalCenter: parent.horizontalCenter } }
            }
        }
    }
    RowLayout { width: parent.width; OmaiSection { text: "Sua saúde"; Layout.fillWidth: true } OmaiStatusBadge { text: "EM DIA" } }
    OmaiDoctorCard { width: parent.width; record: ({title:"Seu próximo encontro",subtitle: patient.state.cancelled ? "Consulta cancelada · Agende um novo horário" : "Dr. João Silva · Cardiologia\n" + (patient.state.rescheduled ? "28 set · 10:00" : "26 set · 14:30") + "  ·  Teleconsulta",icon:"video",badge:patient.state.cancelled ? "Cancelada" : "Confirmada",route:"consultation"}); onActivated: patient.navigate(patient.state.cancelled ? "consultations" : "consultation") }
    OmaiHealthCard { width: parent.width; record: ({title:"Um cuidado para hoje",subtitle:"Losartana 50 mg · 1 comprimido · 08:00",icon:"pill",badge:patient.state.taken ? "Dose registrada" : "Lembrete de medicamento",route:"medications"}); onActivated: patient.navigate("medications") }
    OmaiHealthCard { width: parent.width; record: ({title:"Seu exame chegou",subtitle:"Hemograma completo · 12 ago 2026",icon:"flask",route:"exam"}); onActivated: patient.navigate("exam") }
    OmaiPrescriptionCard { width: parent.width; record: ({title:"Prescrição no seu cofre",subtitle:"Dr. João Silva · Documento digital",icon:"shield",route:"prescription"}); onActivated: patient.navigate("prescription") }
    OmaiSecurityBadge { width: parent.width; text: "Você decide quem participa do seu cuidado." }
    OmaiText { width: parent.width; text: "DEMONSTRAÇÃO · DADOS FICTÍCIOS"; size: 9; color: Theme.muted; horizontalAlignment: Text.AlignHCenter; font.letterSpacing: 1 }
}
