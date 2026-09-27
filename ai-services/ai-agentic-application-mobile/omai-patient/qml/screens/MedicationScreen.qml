import QtQuick
import QtQuick.Controls
import Omai
OmaiPage {
    OmaiText { text: "Seu cuidado de hoje"; size: 27; font.weight: Font.DemiBold; width: parent.width }
    OmaiText { text: "Sábado, 26 de setembro"; color: Theme.muted }
    OmaiCard { width: parent.width; height: med.implicitHeight + 40; color: Theme.tint
        Column { id: med; x: 20; y: 20; width: parent.width - 40; spacing: 14
            OmaiIcon { name: "pill"; width: 36; height: 36 }
            OmaiText { text: "Losartana"; size: 28; font.weight: Font.DemiBold }
            OmaiText { text: "50 mg · 1 comprimido · Uso oral"; width: parent.width }
            OmaiStatusBadge { text: patient.state.taken ? "✓ DOSE REGISTRADA · 08:00" : "HOJE · 08:00" }
            OmaiText { text: "Próxima dose: " + (patient.state.taken ? "amanhã, às 08:00" : "hoje, às 08:00"); size: 12; color: Theme.muted }
        }
    }
    OmaiButton { width: parent.width; text: patient.state.taken ? "Desfazer registro" : "Registrar dose tomada"; secondary: patient.state.taken; onClicked: patient.act("dose") }
    OmaiSection { text: "Acompanhe o tratamento" }
    OmaiDocumentCard { width: parent.width; record: ({title:"Prescrito por Dr. João Silva",subtitle:"CRM-SP 000000 · 12 agosto 2026\nRegistro demonstrativo, sem orientação terapêutica.",icon:"user",route:"prescription"}); onActivated: patient.navigate("prescription") }
    OmaiDocumentCard { width: parent.width; record: ({title:"Histórico de doses",subtitle:(patient.state.taken ? "Hoje · 08:00 · Registrada\n" : "Hoje · Ainda não registrada\n") + "Ontem · 08:02 · Registrada (exemplo)",icon:"clock"}) }
    Switch { text: "Lembretes de medicamento"; checked: patient.state.reminders; onClicked: patient.act("reminders"); font.pixelSize: 14 * Theme.fontScale; palette.windowText: Theme.ink; Accessible.name: text }
    OmaiText { width: parent.width; text: "O lembrete é simulado. Nenhuma notificação do sistema será agendada. Não altere seu tratamento sem orientação profissional."; size: 12; color: Theme.muted }
}
