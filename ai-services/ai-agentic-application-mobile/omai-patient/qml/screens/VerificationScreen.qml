import QtQuick
import QtQuick.Controls
import Omai
OmaiPage {
    OmaiText { text: "Confiança que\npode ser verificada."; size: 28; font.weight: Font.DemiBold; width: parent.width }
    OmaiText { text: "Insira o código da prescrição. Nesta demonstração, escolha um cenário para explorar os resultados."; width: parent.width; color: Theme.muted }
    OmaiTextField { id: code; width: parent.width; text: "OMAI-2026-00842"; placeholderText: "Código da prescrição"; maximumLength: 80 }
    OmaiText { text: "Cenário demonstrativo"; size: 12; color: Theme.muted }
    ComboBox { id: scenario; width: parent.width; height: 52; model: ["Válida", "Expirada", "Revogada", "Assinatura inválida"]; Accessible.name: "Cenário de verificação" }
    OmaiButton { width: parent.width; text: patient.state.verification === "loading" ? "Verificando documento…" : "Verificar documento"; enabled: patient.state.verification !== "loading"; onClicked: patient.verify(code.text, scenario.currentText) }
    BusyIndicator { anchors.horizontalCenter: parent.horizontalCenter; running: patient.state.verification === "loading"; visible: running }
    OmaiCard { visible: patient.state.verification === "valid" || patient.state.verification === "invalid"; width: parent.width; height: result.implicitHeight + 40; color: patient.state.verification === "valid" ? Theme.tint : Theme.warningTint
        Column { id: result; x: 20; y: 20; width: parent.width - 40; spacing: 16
            OmaiIcon { name: patient.state.verification === "valid" ? "shield" : "close"; width: 40; height: 40; color: patient.state.verification === "valid" ? Theme.teal : Theme.warning }
            OmaiText { width: parent.width; text: patient.state.verification === "valid" ? "Prescrição autêntica\n(simulação)" : "Prescrição inválida\n(simulação)"; size: 25; font.weight: Font.DemiBold }
            OmaiText { visible: patient.state.verification === "valid"; width: parent.width; text: "✓ Assinatura verificada — simulado\n✓ Documento não alterado — simulado\n✓ Profissional identificado — simulado\n✓ Dentro da validade — simulado"; size: 13 }
            OmaiText { text: patient.state.verificationReason; width: parent.width; size: 13; color: Theme.muted }
        }
    }
    OmaiText { width: parent.width; text: "A versão de produção exigirá verificação no servidor, cadeia de certificados, assinatura digital, hash, timestamp e consulta de revogação."; size: 12; color: Theme.muted }
}
