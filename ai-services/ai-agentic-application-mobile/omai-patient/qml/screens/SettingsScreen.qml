import QtQuick
import QtQuick.Controls
import Omai
OmaiPage {
    id: root
    signal activated(var record)
    OmaiText { width: parent.width; text: patient.page.subtitle; color: Theme.muted; size: 15 }
    Repeater { model: patient.cards; OmaiDocumentCard { required property var modelData; record: modelData; width: parent.width; onActivated: function(record) { root.activated(record) } } }
    Column { visible: patient.screen === "preferences"; width: parent.width; spacing: 16
        OmaiSection { text: "Aparência" }
        Switch { text: "Modo escuro"; checked: patient.dark; onClicked: patient.dark = checked; font.pixelSize: 16 * Theme.fontScale; palette.windowText: Theme.ink }
        OmaiSection { text: "Tamanho do texto" }
        OmaiText { width: parent.width; text: "Ajuste a leitura para ficar mais confortável."; color: Theme.muted }
        Slider { width: parent.width; from: 1; to: 1.3; stepSize: 0.1; value: Theme.fontScale; onMoved: Theme.fontScale = value; Accessible.name: "Escala de texto" }
        OmaiCard { width: parent.width; height: sample.implicitHeight + 40; OmaiText { id: sample; x: 20; y: 20; width: parent.width - 40; text: "Sua saúde, no seu ritmo.\nUma leitura mais confortável começa aqui." } }
    }
    Column { visible: patient.screen === "security"; width: parent.width; spacing: 12
        OmaiSection { text: "Bloqueio automático" }
        ComboBox { width: parent.width; height: 52; model: ["Após 1 minuto", "Após 5 minutos", "Ao sair do aplicativo"]; Accessible.name: "Tempo para bloqueio automático"; onActivated: patient.notify("Preferência de exemplo. O bloqueio seguro ainda não está integrado.") }
        OmaiText { width: parent.width; text: "Configurações de segurança são demonstrativas e não ativam proteção real neste protótipo."; color: Theme.muted; size: 12 }
    }
    Column { visible: patient.screen === "notifications"; width: parent.width; spacing: 16
        OmaiHealthCard { width: parent.width; record: ({title:"Consulta de hoje",subtitle:"Dr. João Silva · 14:30 · Teleconsulta",icon:"calendar",route:"consultation"}); onActivated: patient.navigate("consultation") }
        Switch { text: "Lembretes de medicamentos"; checked: patient.state.reminders; onClicked: patient.act("reminders"); palette.windowText: Theme.ink }
        OmaiText { width: parent.width; text: "As preferências são mantidas nesta sessão. Notificações do sistema estarão disponíveis após a integração nativa."; color: Theme.muted; size: 12 }
    }
}
