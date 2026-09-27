import QtQuick
import QtQuick.Controls
import Omai
ScrollView {
    id: root
    default property alias contents: stack.data
    contentWidth: availableWidth
    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    Column {
        id: stack
        x: 24; width: root.availableWidth - 48; spacing: 16
        topPadding: 8; bottomPadding: 28
    }
}
