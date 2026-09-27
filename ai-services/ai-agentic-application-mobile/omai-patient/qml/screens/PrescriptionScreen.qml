import QtQuick
import QtQuick.Layouts
import Omai
OmaiPage {
    OmaiStatusBadge { text: "DOCUMENTO DEMONSTRATIVO"; warning: true }
    OmaiCard { width: parent.width; height: prescription.implicitHeight + 48
        Column { id: prescription; x: 24; y: 24; width: parent.width - 48; spacing: 20
            RowLayout { width: parent.width; OmaiLogo { width: 36; height: 36 } Item { Layout.fillWidth: true } OmaiText { text: "PRESCRIÇÃO\nDIGITAL"; size: 10; font.letterSpacing: 2; horizontalAlignment: Text.AlignRight } }
            Rectangle { height: 1; width: parent.width; color: Theme.line }
            OmaiText { text: "Gabriel Barros"; size: 22; font.weight: Font.DemiBold }
            OmaiText { text: "OMAI-2026-00842\nEmitida em 12 ago 2026 · 14:48 BRT\nValidade: 12 nov 2026"; size: 12; color: Theme.muted; width: parent.width }
            OmaiText { text: "Losartana 50 mg"; size: 21; font.weight: Font.DemiBold }
            OmaiText { text: "Exemplo de registro: 1 comprimido, uso oral, às 08:00.\nNão utilizar como prescrição ou orientação médica."; size: 13; width: parent.width }
            Rectangle { height: 1; width: parent.width; color: Theme.line }
            OmaiText { text: "Dr. João Silva\nCardiologia · CRM-SP 000000 (fictício)"; size: 13; width: parent.width }
            OmaiText { text: "Assinatura, integridade e timestamp\nStatus demonstrativo: válida\nNenhum certificado real vinculado."; size: 12; color: Theme.muted; width: parent.width }
        }
    }
    OmaiCard { width: parent.width; height: qrContent.implicitHeight + 40; color: Theme.tint
        Column { id: qrContent; x: 20; y: 20; width: parent.width - 40; spacing: 14
            Rectangle { width: 128; height: 128; color: "white"; radius: 12; anchors.horizontalCenter: parent.horizontalCenter
                Image { source: "qrc:/qt/qml/Omai/assets/prescription-qr.svg"; width: 120; height: 120; anchors.centerIn: parent; Accessible.name: "QR Code com identificador demonstrativo OMAI-2026-00842" }
            }
            OmaiText { text: "Um documento.\nUma identidade verificável."; width: parent.width; size: 20; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter }
            OmaiText { text: "O QR contém o identificador de exemplo. Use o botão abaixo para simular a verificação."; width: parent.width; size: 12; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
        }
    }
    OmaiButton { text: "Verificar autenticidade"; width: parent.width; onClicked: patient.navigate("verification") }
    OmaiSecurityBadge { width: parent.width; text: "Autoria, integridade, validade e revogação." }
}
