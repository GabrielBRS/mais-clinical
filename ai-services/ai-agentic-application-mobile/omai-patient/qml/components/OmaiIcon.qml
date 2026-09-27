import QtQuick
import Omai
Item {
    id: root
    property string name: "heart"
    property color color: Theme.teal
    implicitWidth: 24; implicitHeight: 24
    readonly property var paths: ({
        "heart":"M20.8 4.6 C18.5 2.3 14.9 3.2 12 6 C9.1 3.2 5.5 2.3 3.2 4.6 C-1 9 4 15 12 21 C20 15 25 9 20.8 4.6 Z",
        "home":"M3 10 L12 3 L21 10 L21 21 L15 21 L15 14 L9 14 L9 21 L3 21 Z",
        "spark":"M12 2 Q12 12 22 12 Q12 12 12 22 Q12 12 2 12 Q12 12 12 2 Z M20 2 L20 6 M18 4 L22 4",
        "calendar":"M4 5 L20 5 L20 21 L4 21 Z M8 2 L8 8 M16 2 L16 8 M4 11 L20 11 M8 15 L10 15 M14 15 L16 15",
        "document":"M5 2 L14 2 L20 8 L20 22 L5 22 Z M14 2 L14 8 L20 8 M9 13 L16 13 M9 17 L15 17",
        "flask":"M9 2 L15 2 M10 2 L10 9 L4 19 Q3 22 6 22 L18 22 Q21 22 20 19 L14 9 L14 2 M7 16 L17 16",
        "pill":"M5 19 C-2 12 12 -2 19 5 C26 12 12 26 5 19 Z M8 8 L16 16",
        "shield":"M12 2 L21 6 L20 14 Q18 20 12 23 Q6 20 4 14 L3 6 Z M8 12 L11 15 L17 9",
        "user":"M16 6 A4 4 0 1 1 8 6 A4 4 0 1 1 16 6 M3 22 L3 19 Q3 13 12 13 Q21 13 21 19 L21 22",
        "users":"M16 6 A4 4 0 1 1 8 6 A4 4 0 1 1 16 6 M3 22 L3 19 Q3 13 12 13 Q21 13 21 19 L21 22",
        "arrow":"M4 12 L20 12 M14 6 L20 12 L14 18",
        "back":"M15 5 L8 12 L15 19",
        "chevron":"M9 5 L16 12 L9 19",
        "plus":"M12 4 L12 20 M4 12 L20 12",
        "clock":"M22 12 A10 10 0 1 1 2 12 A10 10 0 1 1 22 12 M12 6 L12 12 L16 15",
        "video":"M2 5 L16 5 L16 19 L2 19 Z M16 10 L22 6 L22 18 L16 14",
        "phone":"M7 2 L17 2 L17 22 L7 22 Z M10 18 L14 18",
        "bell":"M5 17 L19 17 L17 14 L17 8 Q17 3 12 3 Q7 3 7 8 L7 14 Z M10 21 L14 21",
        "key":"M12 7 A5 5 0 1 1 2 7 A5 5 0 1 1 12 7 M11 11 L21 21 M17 17 L20 14",
        "eye":"M1 12 Q12 -2 23 12 Q12 26 1 12 Z M16 12 A4 4 0 1 1 8 12 A4 4 0 1 1 16 12",
        "drop":"M12 2 Q-2 17 6 21 Q12 25 18 21 Q26 17 12 2 Z",
        "grid":"M3 3 L9 3 L9 9 L3 9 Z M15 3 L21 3 L21 9 L15 9 Z M3 15 L9 15 L9 21 L3 21 Z M15 15 L21 15 L21 21 L15 21 Z",
        "sliders":"M3 6 L21 6 M3 12 L21 12 M3 18 L21 18 M8 3 L8 9 M16 9 L16 15 M10 15 L10 21",
        "help":"M22 12 A10 10 0 1 1 2 12 A10 10 0 1 1 22 12 M9 8 Q10 4 14 6 Q18 9 12 12 L12 14 M12 17 L12 18",
        "fingerprint":"M4 17 L4 10 C4 -1 20 -1 20 10 L20 17 M8 21 L8 10 C8 4 16 4 16 10 L16 20 M12 10 L12 23",
        "mic":"M9 4 Q12 -1 15 4 L15 12 Q12 17 9 12 Z M5 11 Q5 21 12 19 Q19 21 19 11 M12 19 L12 23",
        "sound":"M3 9 L7 9 L13 4 L13 20 L7 15 L3 15 Z M17 8 Q21 12 17 16 M20 4 Q27 12 20 20",
        "check":"M5 12 L10 17 L20 6",
        "close":"M5 5 L19 19 M19 5 L5 19",
        "moon":"M20 15 A10 10 0 1 1 9 2 Q4 16 20 15 Z"
    })
    Image {
        anchors.fill: parent
        sourceSize.width: root.width * 2; sourceSize.height: root.height * 2
        source: "data:image/svg+xml;utf8," + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="-1 -1 26 26"><path fill="none" stroke="' + root.color + '" stroke-width="1.65" stroke-linecap="round" stroke-linejoin="round" d="' + (root.paths[root.name] || root.paths["spark"]) + '"/></svg>')
    }
}
