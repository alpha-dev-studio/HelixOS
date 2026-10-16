import QtQuick
import HelixShell

// HelixOS taskbar (Windows-style): Start | search | pinned | tray | clock.
// Interaction wiring lives in Desktop.qml via the aliases below.
Rectangle {
    id: bar
    height: 48
    color: "#F21F1F28"

    property alias startMouse: startMouseArea
    property alias clockMouse: clockMouseArea
    property alias trayMouse: trayMouseArea
    property alias startTint: startGlyph.color
    property string align: "center"
    property bool pinFilesOpen: false
    property bool pinFilesActive: false
    property bool pinStoreOpen: false
    property bool pinStoreActive: false
    property bool pinTerminalOpen: false
    property bool pinTerminalActive: false
    property bool pinSettingsOpen: false
    property bool pinSettingsActive: false
    property alias pinFilesMouse: pinFilesMouseArea
    property alias pinStoreMouse: pinStoreMouseArea
    property alias pinTerminalMouse: pinTerminalMouseArea
    property alias pinSettingsMouse: pinSettingsMouseArea
    property alias clockText: clockLabel.text
    property alias dateText: dateLabel.text

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: "#33333E"
    }

    // Center cluster (Win11-style): Start | search | pinned
    Row {
        id: centerCluster
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: align === "center" ? parent.horizontalCenter : undefined
        x: align === "left" ? 8 : 0
        spacing: 8
    Rectangle {
        id: startBtn
        anchors.verticalCenter: parent.verticalCenter
        width: 48
        height: 48
        color: "transparent"
        Text {
            id: startGlyph
            anchors.centerIn: parent
            text: qsTr("H")
            color: "#00F0FF"
            font.pixelSize: 24
            font.bold: true
            scale: 1.0
        }
        MouseArea {
            id: startMouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
        states: [
            State {
                name: "hover"
                when: startMouseArea.containsMouse && !startMouseArea.pressed
                PropertyChanges { target: startBtn; color: "#2E2E38" }
                PropertyChanges { target: startGlyph; scale: 1.15 }
            },
            State {
                name: "pressed"
                when: startMouseArea.pressed
                PropertyChanges { target: startBtn; color: "#1A1A22" }
                PropertyChanges { target: startGlyph; scale: 0.92 }
            }
        ]
        transitions: Transition {
            ColorAnimation { duration: 120 }
            NumberAnimation { properties: "scale"; duration: 120; easing.type: Easing.OutCubic }
        }
    }

    // Search box (visual; typing works natively, results wire up later)
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 280
        height: 32
        radius: 16
        color: "#16161E"
        border.color: "#33333E"
        border.width: 1
        Text {
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("\u2315")
            color: "#A8A8B0"
            font.pixelSize: 16
        }
        TextInput {
            id: searchInput
            x: 36
            width: 232
            anchors.verticalCenter: parent.verticalCenter
            color: "#F2F2F2"
            font.pixelSize: 13
            clip: true
        }
        Text {
            x: 36
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Type here to search")
            color: "#6E6E78"
            font.pixelSize: 13
            visible: searchInput.text === "" && !searchInput.activeFocus
        }
    }

    // Pinned apps (static: each needs its own click identity)
    Row {
        x: 348
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Rectangle {
            id: pinFiles
            width: 44
            height: 40
            radius: 8
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("F")
                color: "#C6FF00"
                font.pixelSize: 18
                font.bold: true
            }
            Rectangle {
                width: 16
                height: 3
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                color: pinFilesActive ? "#00F0FF" : "#6E6E78"
                visible: pinFilesOpen
            }
            MouseArea {
                id: pinFilesMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: [
                State {
                    name: "hover"
                    when: pinFilesMouseArea.containsMouse && !pinFilesMouseArea.pressed
                    PropertyChanges { target: pinFiles; color: "#2E2E38" }
                },
                State {
                    name: "pressed"
                    when: pinFilesMouseArea.pressed
                    PropertyChanges { target: pinFiles; color: "#1A1A22" }
                }
            ]
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }

        Rectangle {
            id: pinStore
            width: 44
            height: 40
            radius: 8
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("S")
                color: "#F2F2F2"
                font.pixelSize: 18
                font.bold: true
            }
            Rectangle {
                width: 16
                height: 3
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                color: pinStoreActive ? "#00F0FF" : "#6E6E78"
                visible: pinStoreOpen
            }
            MouseArea {
                id: pinStoreMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: [
                State {
                    name: "hover"
                    when: pinStoreMouseArea.containsMouse && !pinStoreMouseArea.pressed
                    PropertyChanges { target: pinStore; color: "#2E2E38" }
                },
                State {
                    name: "pressed"
                    when: pinStoreMouseArea.pressed
                    PropertyChanges { target: pinStore; color: "#1A1A22" }
                }
            ]
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }

        Rectangle {
            id: pinTerminal
            width: 44
            height: 40
            radius: 8
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("T")
                color: "#A8A8B0"
                font.pixelSize: 18
                font.bold: true
            }
            Rectangle {
                width: 16
                height: 3
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                color: pinTerminalActive ? "#00F0FF" : "#6E6E78"
                visible: pinTerminalOpen
            }
            MouseArea {
                id: pinTerminalMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: [
                State {
                    name: "hover"
                    when: pinTerminalMouseArea.containsMouse && !pinTerminalMouseArea.pressed
                    PropertyChanges { target: pinTerminal; color: "#2E2E38" }
                },
                State {
                    name: "pressed"
                    when: pinTerminalMouseArea.pressed
                    PropertyChanges { target: pinTerminal; color: "#1A1A22" }
                }
            ]
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }

        Rectangle {
            id: pinSettings
            width: 44
            height: 40
            radius: 8
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("\u2699")
                color: "#00F0FF"
                font.pixelSize: 18
            }
            Rectangle {
                width: 16
                height: 3
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                color: pinSettingsActive ? "#00F0FF" : "#6E6E78"
                visible: pinSettingsOpen
            }
            MouseArea {
                id: pinSettingsMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: [
                State {
                    name: "hover"
                    when: pinSettingsMouseArea.containsMouse && !pinSettingsMouseArea.pressed
                    PropertyChanges { target: pinSettings; color: "#2E2E38" }
                },
                State {
                    name: "pressed"
                    when: pinSettingsMouseArea.pressed
                    PropertyChanges { target: pinSettings; color: "#1A1A22" }
                }
            ]
                transitions: Transition {
                    ColorAnimation { duration: 120 }
                }
            }
        }
    }

    // Tray + clock cluster
    Row {
        id: trayRow
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        // wifi bars (drawn — zero font risk)
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Rectangle { width: 4; height: 6; anchors.bottom: parent.bottom; color: "#F2F2F2"; radius: 1 }
            Rectangle { width: 4; height: 10; anchors.bottom: parent.bottom; color: "#F2F2F2"; radius: 1 }
            Rectangle { width: 4; height: 14; anchors.bottom: parent.bottom; color: "#00F0FF"; radius: 1 }
        }
        // volume
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("\u266A")
            color: "#F2F2F2"
            font.pixelSize: 16
        }
        // battery (drawn shell + fill + nub)
        Item {
            width: 30
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                width: 24
                height: 14
                radius: 3
                color: "transparent"
                border.color: "#F2F2F2"
                border.width: 1
                Rectangle {
                    x: 2
                    y: 2
                    width: 15
                    height: 10
                    radius: 2
                    color: "#00F0FF"
                }
            }
            Rectangle {
                x: 25
                y: 4
                width: 3
                height: 6
                radius: 1
                color: "#F2F2F2"
            }
        }
        // clock + date
        Item {
            id: clockCol
            width: 76
            height: 34
            anchors.verticalCenter: parent.verticalCenter
            Text {
                id: clockLabel
                anchors.top: parent.top
                anchors.right: parent.right
                text: qsTr("12:00")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            Text {
                id: dateLabel
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                text: qsTr("10/15/2026")
                color: "#A8A8B0"
                font.pixelSize: 11
            }
            MouseArea {
                id: clockMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: clockMouseArea.containsMouse
                PropertyChanges { target: clockLabel; color: "#00F0FF" }
            }
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }
        // show-desktop sliver (hover glow only for now)
        Rectangle {
            id: sliver
            width: 8
            height: 40
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
            border.color: "#33333E"
            border.width: 1
            MouseArea {
                id: sliverMouse
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: sliverMouse.containsMouse
                PropertyChanges { target: sliver; color: "#2E2E38" }
            }
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }
    }

    // tray click zone (clock has its own zone above; sliver keeps its own)
    MouseArea {
        id: trayMouseArea
        anchors.fill: trayRow
    }
}
