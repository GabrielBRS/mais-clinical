import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Omai
ApplicationWindow {
    id: window
    width: 430; height: 900; minimumWidth: 360; minimumHeight: 640
    visible: true; title: "OMAI Patient · Protótipo"
    color: Theme.background
    property bool entry: ["splash", "onboarding", "login"].indexOf(patient.screen) >= 0
    property bool call: patient.screen === "video"
    property string pendingAction: ""
    onClosing: function(close) { if (!entry && patient.screen !== "home") { patient.back(); close.accepted = false } }
    Connections { target: patient; function onChanged() { Theme.dark = patient.dark } }
    Shortcut { sequence: "Alt+Left"; onActivated: patient.back() }
    header: Item {
        visible: !window.entry && !window.call
        height: visible ? (patient.screen === "home" ? 78 : heading.implicitHeight + 34) : 0
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 12
            Button {
                visible: patient.screen !== "home"; implicitWidth: 44; implicitHeight: 48
                Accessible.name: "Voltar"; onClicked: patient.back()
                background: Rectangle { radius: 14; color: Theme.surface; border.color: Theme.line }
                contentItem: OmaiIcon { name: "back"; width: 22; height: 22 }
            }
            OmaiLogo { visible: patient.screen === "home"; width: 34; height: 34 }
            ColumnLayout {
                id: heading; Layout.fillWidth: true; spacing: 2
                OmaiText { text: patient.screen === "home" ? "OMAI" : patient.page.title; size: patient.screen === "home" ? 22 : 19; font.weight: Font.DemiBold; Layout.fillWidth: true }
                OmaiText { visible: patient.screen === "home" || patient.screen === "chat"; text: patient.screen === "home" ? "P A T I E N T" : "Assistente de saúde · Demonstração"; size: 9; color: Theme.muted; Layout.fillWidth: true }
            }
            Button {
                visible: patient.screen === "home"; implicitWidth: 46; implicitHeight: 46; Accessible.name: "Notificações"
                onClicked: patient.navigate("notifications")
                background: Rectangle { radius: 23; color: Theme.surface; border.color: Theme.line }
                contentItem: OmaiIcon { name: "bell" }
            }
            Button {
                visible: patient.screen === "home"; text: "GB"; implicitWidth: 42; implicitHeight: 42; Accessible.name: "Abrir perfil de Gabriel"
                onClicked: patient.navigate("profile")
                background: Rectangle { radius: 21; color: Theme.tint }
                contentItem: OmaiText { text: "GB"; size: 12; color: Theme.teal; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }
    }
    Loader {
        id: loader; anchors.fill: parent
        sourceComponent: {
            switch (patient.screen) {
            case "splash": case "onboarding": case "login": return entryScreen;
            case "home": return homeScreen;
            case "chat": return chatScreen;
            case "assessment": return assessmentScreen;
            case "consultation": return consultationScreen;
            case "video": return videoScreen;
            case "exam": return examScreen;
            case "medications": return medicationScreen;
            case "prescription": return prescriptionScreen;
            case "verification": return verificationScreen;
            case "preferences": case "security": case "notifications": return settingsScreen;
            default: return recordsScreen;
            }
        }
        onLoaded: { item.opacity = 0; arrival.restart() }
        NumberAnimation { id: arrival; target: loader.item; property: "opacity"; to: 1; duration: 200 }
    }
    footer: OmaiBottomNavigation { visible: !window.entry && !window.call; height: visible ? implicitHeight : 0; current: patient.screen; onSelected: function(route) { patient.navigate(route) } }
    Rectangle {
        z: 20; visible: patient.toast.length > 0
        anchors.bottom: parent.bottom; anchors.bottomMargin: 16; anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 32, 440); height: toastText.implicitHeight + 28
        radius: 16; color: Theme.ink
        OmaiText { id: toastText; x: 16; y: 14; width: parent.width - 32; text: patient.toast; size: 12; color: Theme.surface }
        Accessible.role: Accessible.AlertMessage; Accessible.name: patient.toast
    }
    OmaiModal {
        id: confirmation
        onConfirmed: patient.act(window.pendingAction)
    }
    function confirm(action, title, message, label) { pendingAction = action; confirmation.title = title; confirmation.message = message; confirmation.confirmText = label; confirmation.open() }
    function activate(record) {
        if (record.route) patient.navigate(record.route)
        else if (record.action === "revoke-confirm") confirm("revoke", "Revogar acesso?", "A Clínica OMAI perderá acesso a consultas e documentos nesta demonstração. A ação será registrada no histórico de acesso.", "Revogar acesso")
        else if (record.action === "revoke-professional-confirm") confirm("revoke-professional", "Revogar acesso?", "Dr. João Silva perderá acesso ao histórico, exames e prescrições nesta demonstração.", "Revogar acesso")
        else if (record.action) patient.act(record.action)
    }
    Component { id: entryScreen; EntryScreen {} }
    Component { id: homeScreen; HomeScreen {} }
    Component { id: chatScreen; ChatScreen {} }
    Component { id: assessmentScreen; AssessmentScreen {} }
    Component { id: consultationScreen; ConsultationScreen { onConfirmRequested: function(action, title, message, label) { window.confirm(action, title, message, label) } } }
    Component { id: videoScreen; VideoScreen {} }
    Component { id: examScreen; ExamScreen {} }
    Component { id: medicationScreen; MedicationScreen {} }
    Component { id: prescriptionScreen; PrescriptionScreen {} }
    Component { id: verificationScreen; VerificationScreen {} }
    Component { id: settingsScreen; SettingsScreen { onActivated: function(record) { window.activate(record) } } }
    Component { id: recordsScreen; RecordsScreen { onActivated: function(record) { window.activate(record) } } }
}
