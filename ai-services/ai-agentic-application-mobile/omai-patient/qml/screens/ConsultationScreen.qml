import QtQuick
import QtQuick.Layouts
import Omai
OmaiPage {
    signal confirmRequested(string action, string title, string message, string label)
    id: root
    OmaiCard {
        width: parent.width; height: doctor.implicitHeight + 48
        Column {
            id: doctor; x: 24; y: 24; width: parent.width - 48; spacing: 12
            Rectangle { width: 84; height: 84; radius: 30; color: Theme.tint; anchors.horizontalCenter: parent.horizontalCenter; OmaiText { text: "JS"; size: 28; font.weight: Font.DemiBold; color: Theme.teal; anchors.centerIn: parent } }
            OmaiText { width: parent.width; text: "Dr. João Silva"; size: 24; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter }
            OmaiText { width: parent.width; text: "Cardiologia · CRM-SP 000000 (fictício)"; color: Theme.muted; size: 12; horizontalAlignment: Text.AlignHCenter }
            OmaiStatusBadge { anchors.horizontalCenter: parent.horizontalCenter; text: patient.state.cancelled ? "Cancelada" : "Consulta confirmada" }
        }
    }
    OmaiHealthCard { width: parent.width; record: ({title:patient.state.rescheduled ? "28 de setembro de 2026" : "26 de setembro de 2026",subtitle:patient.state.rescheduled ? "10:00 · Horário de Brasília" : "14:30 · Horário de Brasília",icon:"calendar"}) }
    OmaiHealthCard { width: parent.width; record: ({title:"Teleconsulta",subtitle:"Seu encontro acontece por aqui.\nNesta demonstração, câmera e áudio não são capturados.",icon:"video"}) }
    OmaiSection { text: "Antes do seu encontro" }
    OmaiText { width: parent.width; text: "Encontre um lugar tranquilo e tenha seus exames à mão. Seu resumo OMAI pode ajudar na conversa."; color: Theme.muted }
    OmaiButton { width: parent.width; text: "Entrar na consulta  ↗"; enabled: !patient.state.cancelled; onClicked: patient.navigate("video") }
    OmaiButton { width: parent.width; text: "Reagendar"; secondary: true; onClicked: root.confirmRequested("reschedule", "Novo horário", "Horário demonstrativo disponível: 28 de setembro de 2026 às 10:00, com Dr. João Silva.", "Confirmar novo horário") }
    OmaiButton { width: parent.width; text: "Cancelar consulta"; danger: true; enabled: !patient.state.cancelled; onClicked: root.confirmRequested("cancel", "Cancelar consulta?", "A consulta será movida para Canceladas nesta sessão demonstrativa.", "Cancelar consulta") }
}
