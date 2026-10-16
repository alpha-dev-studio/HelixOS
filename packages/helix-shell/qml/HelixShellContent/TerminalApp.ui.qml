import QtQuick
import HelixShell

// HelixOS Terminal: transcript + live prompt with blinking cursor.
Rectangle {
    id: win
    width: 720
    height: 460
    radius: 10
    color: "#0B0E1A"
    border.color: "#3A3A46"
    border.width: 1
    clip: true

    property alias closeMouse: closeMouseArea
    property alias minMouse: minMouseArea
    property alias maxMouse: maxMouseArea

    Rectangle {
        height: 42
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: "#1C1C24"
        Text {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Terminal — helix@helix")
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

    Column {
        x: 18
        y: 58
        width: parent.width - 36
        spacing: 4
        Text {
            text: qsTr("HelixOS 1.0 Surge — helix@helix:~$")
            color: "#6E6E78"
            font.pixelSize: 14
            font.family: "monospace"
        }
        Text {
            text: qsTr("helix@helix:~$ neofetch")
            color: "#F2F2F2"
            font.pixelSize: 14
            font.family: "monospace"
        }
        Text {
            text: qsTr("OS: HelixOS 1.0 Surge x86_64   Shell: helix-shell 1.0")
            color: "#00F0FF"
            font.pixelSize: 14
            font.family: "monospace"
        }
        Text {
            text: qsTr("Kernel: 6.12   DE: Helix   Uptime: 42 mins")
            color: "#00F0FF"
            font.pixelSize: 14
            font.family: "monospace"
        }
        Row {
            spacing: 6
            Text {
                text: qsTr("helix@helix:~$")
                color: "#C6FF00"
                font.pixelSize: 14
                font.bold: true
                font.family: "monospace"
            }
            TextInput {
                width: 480
                color: "#F2F2F2"
                font.pixelSize: 14
                font.family: "monospace"
                focus: true
            }
            Rectangle {
                id: caret
                width: 9
                height: 18
                anchors.verticalCenter: parent.verticalCenter
                color: "#F2F2F2"
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.0; duration: 530 }
                    NumberAnimation { to: 1.0; duration: 530 }
                }
            }
        }
    }
}
