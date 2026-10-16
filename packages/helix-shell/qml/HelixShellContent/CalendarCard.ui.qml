import QtQuick
import HelixShell

// HelixOS calendar flyout: real month grid fed from Desktop.qml
// (`days`: 42 cells, "" for blanks; `todayIndex`: highlight cell or -1).
Rectangle {
    id: card
    width: 360
    height: 380
    radius: 12
    color: "#F226262E"
    border.color: "#3A3A46"
    border.width: 1

    property bool open: false
    property var days: []
    property string monthTitle: ""
    property int todayIndex: -1
    property alias prevMouse: prevMouseArea
    property alias nextMouse: nextMouseArea

    opacity: open ? 1.0 : 0.0
    visible: opacity > 0.0

    Behavior on opacity {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    Row {
        x: 16
        y: 14
        width: parent.width - 32
        Text {
            text: qsTr("\u276E")
            color: "#A8A8B0"
            font.pixelSize: 18
            MouseArea {
                id: prevMouseArea
                anchors.fill: parent
            }
        }
        Text {
            width: parent.width - 60
            text: monthTitle
            color: "#F2F2F2"
            font.pixelSize: 16
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            text: qsTr("\u276F")
            color: "#A8A8B0"
            font.pixelSize: 18
            MouseArea {
                id: nextMouseArea
                anchors.fill: parent
            }
        }
    }

    Row {
        x: 20
        y: 52
        spacing: 0
        Repeater {
            model: ["S", "M", "T", "W", "T", "F", "S"]
            delegate: Text {
                width: 46
                text: modelData
                color: "#6E6E78"
                font.pixelSize: 12
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Grid {
        x: 20
        y: 80
        columns: 7
        columnSpacing: 2
        rowSpacing: 2
        Repeater {
            model: days
            delegate: Rectangle {
                width: 44
                height: 34
                radius: 17
                color: index === todayIndex ? "#00F0FF" : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: index === todayIndex ? "#04222A" : "#F2F2F2"
                    font.pixelSize: 13
                    font.bold: index === todayIndex
                }
            }
        }
    }
}
