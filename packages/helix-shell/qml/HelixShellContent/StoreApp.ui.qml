import QtQuick
import QtQuick.Controls
import HelixShell

// HelixOS Store: featured install with live progress + app grid.
// Install flow is driven from Desktop.qml.
Rectangle {
    id: win
    width: 900
    height: 600
    radius: 10
    color: "#26262E"
    border.color: "#3A3A46"
    border.width: 1
    clip: true

    property bool installing: false
    property real progress: 0.0
    property bool installed: false
    property alias closeMouse: closeMouseArea
    property alias minMouse: minMouseArea
    property alias maxMouse: maxMouseArea
    property alias installMouse: installMouseArea

    Rectangle {
        height: 42
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: "#1C1C24"
        Text {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Helix Store")
            color: "#F2F2F2"
            font.pixelSize: 14
            font.bold: true
        }
        MouseArea {
            anchors.fill: parent
            drag.target: win
            drag.axis: Drag.XAndYAxis
        }
        Rectangle {
            id: maxBtn
            width: 46
            height: 42
            anchors.right: parent.right
            anchors.rightMargin: 46
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("\u25A2")
                color: "#F2F2F2"
                font.pixelSize: 12
            }
            MouseArea {
                id: maxMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: maxMouseArea.containsMouse
                PropertyChanges { target: maxBtn; color: "#2E2E38" }
            }
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }
        Rectangle {
            id: minBtn
            width: 46
            height: 42
            anchors.right: parent.right
            anchors.rightMargin: 92
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("\u2212")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: minMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: minMouseArea.containsMouse
                PropertyChanges { target: minBtn; color: "#2E2E38" }
            }
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }
        Rectangle {
            id: closeBtn
            width: 46
            height: 42
            anchors.right: parent.right
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("\u2715")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: closeMouseArea.containsMouse
                PropertyChanges { target: closeBtn; color: "#C42B1C" }
            }
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }
    }

    // featured app
    Rectangle {
        x: 24
        y: 64
        width: parent.width - 48
        height: 170
        radius: 12
        color: "#34343E"

        Rectangle {
            x: 20
            width: 96
            height: 96
            anchors.verticalCenter: parent.verticalCenter
            radius: 20
            color: "#00F0FF"
            Text {
                anchors.centerIn: parent
                text: qsTr("P")
                color: "#04222A"
                font.pixelSize: 44
                font.bold: true
            }
        }
        Text {
            x: 136
            y: 24
            text: qsTr("Helix Paint")
            color: "#F2F2F2"
            font.pixelSize: 24
            font.bold: true
        }
        Text {
            x: 136
            y: 60
            text: qsTr("Draw, sketch and annotate. Free.")
            color: "#A8A8B0"
            font.pixelSize: 14
        }
        ProgressBar {
            x: 136
            y: 96
            width: 420
            value: progress
            visible: installing || installed
        }
        Rectangle {
            id: installBtn
            x: 136
            y: 118
            width: 150
            height: 36
            radius: 8
            color: installed ? "#1C1C24" : "#00F0FF"
            Text {
                anchors.centerIn: parent
                text: installed ? qsTr("Installed") : (installing ? (Math.round(progress * 100) + qsTr("%")) : qsTr("Install"))
                color: installed ? "#A8A8B0" : "#04222A"
                font.pixelSize: 14
                font.bold: true
            }
            MouseArea {
                id: installMouseArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: !installed && !installing
            }
            states: State {
                name: "hover"
                when: installMouseArea.containsMouse
                PropertyChanges { target: installBtn; color: "#33F5FF" }
            }
            transitions: Transition {
                ColorAnimation { duration: 130 }
            }
        }
    }

    Text {
        x: 24
        y: 252
        text: qsTr("Top apps")
        color: "#F2F2F2"
        font.pixelSize: 16
        font.bold: true
    }

    Grid {
        x: 24
        y: 284
        columns: 3
        columnSpacing: 14
        rowSpacing: 14
        Repeater {
            model: ListModel {
                ListElement { glyph: "M"; name: "Music"; tint: "#7A00FF"; desc: "Play your library" }
                ListElement { glyph: "V"; name: "Videos"; tint: "#C6FF00"; desc: "Watch anything" }
                ListElement { glyph: "W"; name: "Web"; tint: "#00F0FF"; desc: "Fast browsing" }
                ListElement { glyph: "N"; name: "Notes"; tint: "#F2F2F2"; desc: "Capture ideas" }
                ListElement { glyph: "C"; name: "Calendar"; tint: "#A8A8B0"; desc: "Plan the week" }
                ListElement { glyph: "G"; name: "Games"; tint: "#7A00FF"; desc: "Play time" }
            }
            delegate: Rectangle {
                id: appCard
                width: 270
                height: 120
                radius: 10
                color: "#34343E"
                Rectangle {
                    x: 14
                    y: 14
                    width: 52
                    height: 52
                    radius: 12
                    color: "#2E2E38"
                    Text {
                        anchors.centerIn: parent
                        text: glyph
                        color: tint
                        font.pixelSize: 24
                        font.bold: true
                    }
                }
                Text {
                    x: 78
                    y: 16
                    text: name
                    color: "#F2F2F2"
                    font.pixelSize: 15
                    font.bold: true
                }
                Text {
                    x: 78
                    y: 42
                    text: desc
                    color: "#A8A8B0"
                    font.pixelSize: 12
                }
                Text {
                    x: 78
                    y: 82
                    text: qsTr("Get")
                    color: "#00F0FF"
                    font.pixelSize: 13
                    font.bold: true
                }
                MouseArea {
                    id: cardMouse
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: cardMouse.containsMouse
                    PropertyChanges { target: appCard; color: "#3E3E48" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 130 }
                }
            }
        }
    }
}
