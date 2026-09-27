import QtQuick
import Omai
Text {
    property int size: Theme.body
    font.family: Theme.family
    font.pixelSize: size * Theme.fontScale
    color: Theme.ink
    wrapMode: Text.WordWrap
    lineHeight: 1.2
    Accessible.role: Accessible.StaticText
    Accessible.name: text
}
