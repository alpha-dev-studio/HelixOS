import QtQuick
import HelixShell

// HelixOS Alt-Tab switcher: `selected` is driven from Desktop.qml
// while Alt is held.
Row {
    id: switcher
    spacing: 16

    property int selected: 0

    Repeater {
        model: ListModel {
            ListElement { glyph: "F"; name: "Files"; tint: "#C6FF00" }
            ListElement { glyph: "S"; name: "Helix Store"; tint: "#F2F2F2" }
            ListElement { glyph: "T"; name: "Terminal"; tint: "#A8A8B0" }
        }
        delegate: Rectangle {
            width: 220
            height: 150
            radius: 12
            color: "#26262E"
            border.color: index === selected ? "#00F0FF" : "#3A3A46"
            border.width: index === selected ? 3 : 1
            scale: index === selected ? 1.05 : 1.0

            Behavior on scale {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -14
                text: glyph
                color: tint
                font.pixelSize: 52
                font.bold: true
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                anchors.horizontalCenter: parent.horizontalCenter
                text: name
                color: "#F2F2F2"
                font.pixelSize: 14
            }
        }
    }
}
