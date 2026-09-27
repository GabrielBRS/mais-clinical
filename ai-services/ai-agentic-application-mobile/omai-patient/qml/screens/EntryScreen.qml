import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Omai
OmaiPage {
    id: root
    property int onboardingStep: 0
    property bool signup: false
    readonly property var titles: ["Saúde inteligente,\nsempre com você.", "Uma conversa.\nMais cuidado.", "Sua história,\nem um só lugar.", "Seus dados.\nSuas escolhas."]
    readonly property var descriptions: ["Conheça uma nova forma de cuidar de você. Mais simples, conectada e humana.", "Organize seus sintomas com a OMAI e prepare o próximo encontro com seu médico.", "Consultas, exames e prescrições conectados à sua jornada de saúde.", "Decida quem pode acessar suas informações e acompanhe cada acesso."]
    Timer { interval: 1600; running: patient.screen === "splash"; onTriggered: patient.navigate("onboarding") }
    Item { width: parent.width; height: patient.screen === "login" ? 32 : 60 }
    OmaiLogo { width: patient.screen === "splash" ? 94 : 56; height: width; anchors.horizontalCenter: parent.horizontalCenter
        SequentialAnimation on opacity { running: patient.screen === "splash"; loops: Animation.Infinite; NumberAnimation { to: 0.4; duration: 700 } NumberAnimation { to: 1; duration: 700 } }
    }
    OmaiText { width: parent.width; horizontalAlignment: Text.AlignHCenter; text: "OMAI"; size: 32; font.weight: Font.DemiBold; font.letterSpacing: 5 }
    OmaiText { width: parent.width; horizontalAlignment: Text.AlignHCenter; text: patient.screen === "splash" ? "Oziel Medical Artificial Intelligence\n\nP A T I E N T" : "S E U   C U I D A D O ,   C O N E C T A D O"; size: 10; color: Theme.muted }
    Rectangle {
        visible: patient.screen === "onboarding"; width: parent.width; height: 220; radius: 36
        gradient: Gradient { GradientStop { position: 0; color: Theme.tint } GradientStop { position: 1; color: Theme.background } }
        Repeater { model: 3; Rectangle { required property int index; width: 115 + index * 42; height: width; radius: width / 2; border.color: Theme.line; color: "transparent"; anchors.centerIn: parent } }
        Rectangle { width: 88; height: 88; radius: 28; color: Theme.surface; anchors.centerIn: parent; rotation: -8
            OmaiIcon { width: 42; height: 42; anchors.centerIn: parent; rotation: 8; name: ["heart","spark","document","shield"][root.onboardingStep] }
        }
        OmaiStatusBadge { text: "Cuidado que conecta"; anchors.horizontalCenter: parent.horizontalCenter; y: 174 }
    }
    OmaiText { visible: patient.screen !== "splash"; width: parent.width; text: patient.screen === "login" ? (root.signup ? "Comece sua jornada" : "Bom ter você aqui.") : root.titles[root.onboardingStep]; size: 32; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter }
    OmaiText { visible: patient.screen !== "splash"; width: parent.width; text: patient.screen === "login" ? "Entre para cuidar da sua saúde, no seu tempo." : root.descriptions[root.onboardingStep]; size: 14; color: Theme.muted; horizontalAlignment: Text.AlignHCenter }
    Row { visible: patient.screen === "onboarding"; anchors.horizontalCenter: parent.horizontalCenter; spacing: 6; padding: 12
        Repeater { model: 4; Rectangle { required property int index; width: index === root.onboardingStep ? 24 : 6; height: 6; radius: 3; color: index === root.onboardingStep ? Theme.teal : Theme.line } }
    }
    OmaiTextField { id: email; visible: patient.screen === "login"; width: parent.width; placeholderText: "Seu e-mail"; inputMethodHints: Qt.ImhEmailCharactersOnly }
    OmaiTextField { id: password; visible: patient.screen === "login"; width: parent.width; placeholderText: "Senha · mínimo de 6 caracteres"; echoMode: TextInput.Password; onAccepted: patient.login(email.text, password.text, root.signup) }
    OmaiButton { visible: patient.screen === "onboarding"; width: parent.width; text: root.onboardingStep < 3 ? "Continuar  →" : "Começar"; onClicked: { if (root.onboardingStep < 3) root.onboardingStep++; else patient.navigate("login") } }
    OmaiButton { visible: patient.screen === "login"; width: parent.width; text: root.signup ? "Criar conta demonstrativa" : "Entrar"; onClicked: patient.login(email.text, password.text, root.signup) }
    OmaiButton { visible: patient.screen !== "splash"; width: parent.width; secondary: true; text: patient.screen === "onboarding" ? "Já tenho conta" : "Explorar demonstração"; onClicked: { if (patient.screen === "onboarding") patient.navigate("login"); else patient.act("demo-login") } }
    OmaiButton { visible: patient.screen === "login"; width: parent.width; secondary: true; text: root.signup ? "Já tenho conta · Entrar" : "Ainda não tem conta? Criar conta"; onClicked: root.signup = !root.signup }
    OmaiButton { visible: patient.screen === "login"; width: parent.width; secondary: true; text: "Biometria / passkey · Em breve"; onClicked: patient.act("biometry") }
    OmaiSecurityBadge { visible: patient.screen !== "splash"; width: parent.width; text: "Ambiente demonstrativo. Use dados fictícios." }
}
