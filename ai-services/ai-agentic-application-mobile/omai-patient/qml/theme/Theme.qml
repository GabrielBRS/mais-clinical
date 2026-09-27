pragma Singleton
import QtQuick
QtObject {
    property bool dark: false
    property real fontScale: 1
    readonly property color background: dark ? "#101C20" : "#F5F8F8"
    readonly property color surface: dark ? "#192A30" : "#FFFFFF"
    readonly property color ink: dark ? "#EFF7F6" : "#173C40"
    readonly property color muted: dark ? "#A4BBC0" : "#637D80"
    readonly property color line: dark ? "#30464D" : "#E2ECEB"
    readonly property color teal: dark ? "#6DDAC9" : "#12776B"
    readonly property color tint: dark ? "#203E3D" : "#E6F4F0"
    readonly property color blue: dark ? "#20374D" : "#EBF2FA"
    readonly property color warning: dark ? "#F6BDA9" : "#9C452E"
    readonly property color warningTint: dark ? "#472C29" : "#FFF0E9"
    readonly property int space: 8
    readonly property int radius: 24
    readonly property int smallRadius: 14
    readonly property int duration: 180
    readonly property int touch: 48
    readonly property int body: 14
    readonly property int heading: 28
    readonly property real elevation: 0.06
    readonly property string family: "Segoe UI"
}
