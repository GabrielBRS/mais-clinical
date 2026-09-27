import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Omai
OmaiPage {
    id: root
    signal activated(var record)
    OmaiText { width: parent.width; text: patient.page.subtitle || ""; size: 15; color: Theme.muted }
    OmaiCard {
        visible: patient.screen === "profile"; width: parent.width; height: 116
        RowLayout { anchors.fill: parent; anchors.margins: 22; spacing: 16
            Rectangle { width: 64; height: 64; radius: 24; color: Theme.tint; OmaiText { text: "GB"; size: 24; color: Theme.teal; anchors.centerIn: parent; font.weight: Font.DemiBold } }
            ColumnLayout { Layout.fillWidth: true; OmaiText { text: "Gabriel Barros"; size: 20; font.weight: Font.DemiBold } OmaiText { text: "Uma jornada de cuidado, só sua."; size: 12; color: Theme.muted; Layout.fillWidth: true } }
        }
    }
    OmaiCard { visible: patient.screen === "privacy"; width: parent.width; height: privacyIntro.implicitHeight + 40; color: Theme.tint
        Column { id: privacyIntro; x: 20; y: 20; width: parent.width - 40; spacing: 12; OmaiIcon { name: "shield"; width: 32; height: 32 } OmaiText { width: parent.width; text: "Compartilhar é uma escolha sua."; size: 23; font.weight: Font.DemiBold } OmaiText { width: parent.width; text: "Veja quem tem acesso, quais informações são compartilhadas e por quanto tempo."; size: 13; color: Theme.muted } }
    }
    Flickable {
        visible: !!patient.page.filters; width: parent.width; height: visible ? 56 : 0; contentWidth: chips.implicitWidth; clip: true; boundsBehavior: Flickable.StopAtBounds
        Row { id: chips; spacing: 8
            Repeater { model: patient.page.filters || []
                OmaiButton { required property string modelData; text: modelData; implicitWidth: Math.max(90, naturalWidth); secondary: patient.filter !== modelData; onClicked: patient.setFilter(modelData) }
            }
        }
    }
    OmaiSection { visible: patient.screen === "history"; text: "2026" }
    Repeater { model: patient.cards
        OmaiDocumentCard { required property var modelData; width: parent.width; record: modelData; onActivated: function(record) { root.activated(record) } }
    }
    OmaiText { visible: patient.cards.length === 0; width: parent.width; text: "Nenhum registro por aqui. Novos documentos aparecerão nesta área."; color: Theme.muted; padding: 20 }
    OmaiButton { visible: patient.screen === "consultations"; width: parent.width; text: "Agendar consulta"; onClicked: patient.act("book") }
    OmaiButton { visible: patient.screen === "profile"; width: parent.width; text: "Sair da conta"; secondary: true; onClicked: patient.act("logout") }
    OmaiButton { visible: patient.screen === "professional-access"; width: parent.width; text: patient.state.professionalRevoked ? "Acesso revogado" : "Revogar acesso"; danger: true; enabled: !patient.state.professionalRevoked; onClicked: root.activated({action:"revoke-professional-confirm"}) }
    OmaiSecurityBadge { width: parent.width; text: "Dados fictícios · Alterações válidas nesta sessão" }
}
