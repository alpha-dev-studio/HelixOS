import QtQuick
import HelixShell

// HelixOS Start menu (Win11-style): search + pinned icon grid + recent +
// all-apps view + user bar. Launches driven from Desktop.qml.
Rectangle {
    id: menu
    width: 640
    height: 660
    radius: 12
    color: "#F226262E"
    border.color: "#3A3A46"
    border.width: 1

    property bool open: false
    property bool paintInstalled: false
    property string userName: "helix"
    property string view: "main"
    property alias tileFilesMouse: tileFilesMouseArea
    property alias tileStoreMouse: tileStoreMouseArea
    property alias tileTerminalMouse: tileTerminalMouseArea
    property alias tileCalcMouse: tileCalcMouseArea
    property alias tileTaskmgrMouse: tileTaskmgrMouseArea
    property alias tileSettingsMouse: tileSettingsMouseArea
    property alias tilePaintMouse: tilePaintMouseArea
    property alias rowFilesMouse: rowFilesMouseArea
    property alias rowStoreMouse: rowStoreMouseArea
    property alias rowSettingsMouse: rowSettingsMouseArea
    property alias rowPaintMouse: rowPaintMouseArea
    property alias allFilesMouse: allFilesMouseArea
    property alias allStoreMouse: allStoreMouseArea
    property alias allTerminalMouse: allTerminalMouseArea
    property alias allCalcMouse: allCalcMouseArea
    property alias allTaskmgrMouse: allTaskmgrMouseArea
    property alias allSettingsMouse: allSettingsMouseArea
    property alias allPaintMouse: allPaintMouseArea
    property alias showAllMouse: showAllMouseArea
    property alias backMouse: backMouseArea
    property alias powerMouse: powerMouseArea

    opacity: open ? 1.0 : 0.0
    visible: opacity > 0.0

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    // search (typing works; filtering wires up later)
    Rectangle {
        x: 24
        y: 14
        width: parent.width - 48
        height: 36
        radius: 18
        color: "#16161E"
        border.color: "#33333E"
        border.width: 1
        Text {
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("\u2315")
            color: "#A8A8B0"
            font.pixelSize: 16
        }
        TextInput {
            id: menuSearch
            x: 40
            width: parent.width - 56
            anchors.verticalCenter: parent.verticalCenter
            color: "#F2F2F2"
            font.pixelSize: 13
            clip: true
        }
        Text {
            x: 40
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Search for apps, settings, and documents")
            color: "#6E6E78"
            font.pixelSize: 13
            visible: menuSearch.text === "" && !menuSearch.activeFocus
        }
    }

    // ---- main view ----
    Item {
        anchors.fill: parent
        visible: view === "main"

        Row {
            x: 32
            y: 66
            width: parent.width - 64
            Text {
                text: qsTr("Pinned")
                color: "#F2F2F2"
                font.pixelSize: 14
                font.bold: true
            }
            Item {
                width: 430
                height: 1
            }
            Text {
                text: qsTr("Show all  >")
                color: "#F2F2F2"
                font.pixelSize: 12
                MouseArea {
                    id: showAllMouseArea
                    anchors.fill: parent
                }
            }
        }

        Grid {
            x: 32
            y: 100
            columns: 6
            columnSpacing: 8
            rowSpacing: 14

            Column {
                width: 92
                spacing: 6
                Rectangle {
                    id: tileFiles
                    width: 56
                    height: 56
                    radius: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("F")
                        color: "#C6FF00"
                        font.pixelSize: 24
                        font.bold: true
                    }
                    MouseArea {
                        id: tileFilesMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    states: [
                        State {
                            name: "hover"
                            when: tileFilesMouseArea.containsMouse && !tileFilesMouseArea.pressed
                            PropertyChanges { target: tileFiles; color: "#3E3E48" }
                        },
                        State {
                            name: "pressed"
                            when: tileFilesMouseArea.pressed
                            PropertyChanges { target: tileFiles; color: "#2A2A32" }
                        }
                    ]
                    transitions: Transition {
                        ColorAnimation { duration: 130 }
                    }
                }
                Text {
                    text: qsTr("Files")
                    color: "#F2F2F2"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                width: 92
                spacing: 6
                Rectangle {
                    id: tileStore
                    width: 56
                    height: 56
                    radius: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("S")
                        color: "#F2F2F2"
                        font.pixelSize: 24
                        font.bold: true
                    }
                    MouseArea {
                        id: tileStoreMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    states: [
                        State {
                            name: "hover"
                            when: tileStoreMouseArea.containsMouse && !tileStoreMouseArea.pressed
                            PropertyChanges { target: tileStore; color: "#3E3E48" }
                        },
                        State {
                            name: "pressed"
                            when: tileStoreMouseArea.pressed
                            PropertyChanges { target: tileStore; color: "#2A2A32" }
                        }
                    ]
                    transitions: Transition {
                        ColorAnimation { duration: 130 }
                    }
                }
                Text {
                    text: qsTr("Helix Store")
                    color: "#F2F2F2"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                width: 92
                spacing: 6
                Rectangle {
                    id: tileTerminal
                    width: 56
                    height: 56
                    radius: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("T")
                        color: "#A8A8B0"
                        font.pixelSize: 24
                        font.bold: true
                    }
                    MouseArea {
                        id: tileTerminalMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    states: [
                        State {
                            name: "hover"
                            when: tileTerminalMouseArea.containsMouse && !tileTerminalMouseArea.pressed
                            PropertyChanges { target: tileTerminal; color: "#3E3E48" }
                        },
                        State {
                            name: "pressed"
                            when: tileTerminalMouseArea.pressed
                            PropertyChanges { target: tileTerminal; color: "#2A2A32" }
                        }
                    ]
                    transitions: Transition {
                        ColorAnimation { duration: 130 }
                    }
                }
                Text {
                    text: qsTr("Terminal")
                    color: "#F2F2F2"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                width: 92
                spacing: 6
                Rectangle {
                    id: tileCalc
                    width: 56
                    height: 56
                    radius: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("=")
                        color: "#00F0FF"
                        font.pixelSize: 24
                        font.bold: true
                    }
                    MouseArea {
                        id: tileCalcMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    states: [
                        State {
                            name: "hover"
                            when: tileCalcMouseArea.containsMouse && !tileCalcMouseArea.pressed
                            PropertyChanges { target: tileCalc; color: "#3E3E48" }
                        },
                        State {
                            name: "pressed"
                            when: tileCalcMouseArea.pressed
                            PropertyChanges { target: tileCalc; color: "#2A2A32" }
                        }
                    ]
                    transitions: Transition {
                        ColorAnimation { duration: 130 }
                    }
                }
                Text {
                    text: qsTr("Calculator")
                    color: "#F2F2F2"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                width: 92
                spacing: 6
                Rectangle {
                    id: tileTaskmgr
                    width: 56
                    height: 56
                    radius: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("%")
                        color: "#7A00FF"
                        font.pixelSize: 24
                        font.bold: true
                    }
                    MouseArea {
                        id: tileTaskmgrMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    states: [
                        State {
                            name: "hover"
                            when: tileTaskmgrMouseArea.containsMouse && !tileTaskmgrMouseArea.pressed
                            PropertyChanges { target: tileTaskmgr; color: "#3E3E48" }
                        },
                        State {
                            name: "pressed"
                            when: tileTaskmgrMouseArea.pressed
                            PropertyChanges { target: tileTaskmgr; color: "#2A2A32" }
                        }
                    ]
                    transitions: Transition {
                        ColorAnimation { duration: 130 }
                    }
                }
                Text {
                    text: qsTr("Task Manager")
                    color: "#F2F2F2"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                width: 92
                spacing: 6
                Rectangle {
                    id: tileSettings
                    width: 56
                    height: 56
                    radius: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("\u2699")
                        color: "#F2F2F2"
                        font.pixelSize: 24
                    }
                    MouseArea {
                        id: tileSettingsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    states: [
                        State {
                            name: "hover"
                            when: tileSettingsMouseArea.containsMouse && !tileSettingsMouseArea.pressed
                            PropertyChanges { target: tileSettings; color: "#3E3E48" }
                        },
                        State {
                            name: "pressed"
                            when: tileSettingsMouseArea.pressed
                            PropertyChanges { target: tileSettings; color: "#2A2A32" }
                        }
                    ]
                    transitions: Transition {
                        ColorAnimation { duration: 130 }
                    }
                }
                Text {
                    text: qsTr("Settings")
                    color: "#F2F2F2"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                width: 92
                spacing: 6
                visible: paintInstalled
                Rectangle {
                    id: tilePaint
                    width: 56
                    height: 56
                    radius: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("P")
                        color: "#00F0FF"
                        font.pixelSize: 24
                        font.bold: true
                    }
                    MouseArea {
                        id: tilePaintMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    states: [
                        State {
                            name: "hover"
                            when: tilePaintMouseArea.containsMouse && !tilePaintMouseArea.pressed
                            PropertyChanges { target: tilePaint; color: "#3E3E48" }
                        },
                        State {
                            name: "pressed"
                            when: tilePaintMouseArea.pressed
                            PropertyChanges { target: tilePaint; color: "#2A2A32" }
                        }
                    ]
                    transitions: Transition {
                        ColorAnimation { duration: 130 }
                    }
                }
                Text {
                    text: qsTr("Helix Paint")
                    color: "#F2F2F2"
                    font.pixelSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        Text {
            x: 32
            y: 330
            text: qsTr("Recent")
            color: "#F2F2F2"
            font.pixelSize: 14
            font.bold: true
        }

        Grid {
            x: 32
            y: 360
            columns: 2
            columnSpacing: 16
            rowSpacing: 8

            Rectangle {
                id: rowPaintRecent
                width: 280
                height: 56
                radius: 8
                color: "transparent"
                visible: paintInstalled
                Rectangle {
                    x: 8
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 8
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("P")
                        color: "#00F0FF"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
                Text {
                    x: 54
                    y: 8
                    text: qsTr("Helix Paint")
                    color: "#F2F2F2"
                    font.pixelSize: 13
                }
                Text {
                    x: 54
                    y: 28
                    text: qsTr("Recently added")
                    color: "#A8A8B0"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: rowPaintMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: rowPaintMouseArea.containsMouse
                    PropertyChanges { target: rowPaintRecent; color: "#2E2E38" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 120 }
                }
            }

            Rectangle {
                id: rowFiles
                width: 280
                height: 56
                radius: 8
                color: "transparent"
                Rectangle {
                    x: 8
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 8
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("F")
                        color: "#C6FF00"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
                Text {
                    x: 54
                    y: 8
                    text: qsTr("Files")
                    color: "#F2F2F2"
                    font.pixelSize: 13
                }
                Text {
                    x: 54
                    y: 28
                    text: qsTr("Pinned for quick access")
                    color: "#A8A8B0"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: rowFilesMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: rowFilesMouseArea.containsMouse
                    PropertyChanges { target: rowFiles; color: "#2E2E38" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 120 }
                }
            }

            Rectangle {
                id: rowStore
                width: 280
                height: 56
                radius: 8
                color: "transparent"
                Rectangle {
                    x: 8
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 8
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("S")
                        color: "#F2F2F2"
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
                Text {
                    x: 54
                    y: 8
                    text: qsTr("Helix Store")
                    color: "#F2F2F2"
                    font.pixelSize: 13
                }
                Text {
                    x: 54
                    y: 28
                    text: qsTr("New apps weekly")
                    color: "#A8A8B0"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: rowStoreMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: rowStoreMouseArea.containsMouse
                    PropertyChanges { target: rowStore; color: "#2E2E38" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 120 }
                }
            }

            Rectangle {
                id: rowSettings
                width: 280
                height: 56
                radius: 8
                color: "transparent"
                Rectangle {
                    x: 8
                    width: 36
                    height: 36
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 8
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("\u2699")
                        color: "#00F0FF"
                        font.pixelSize: 16
                    }
                }
                Text {
                    x: 54
                    y: 8
                    text: qsTr("Settings")
                    color: "#F2F2F2"
                    font.pixelSize: 13
                }
                Text {
                    x: 54
                    y: 28
                    text: qsTr("Make it yours")
                    color: "#A8A8B0"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: rowSettingsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: rowSettingsMouseArea.containsMouse
                    PropertyChanges { target: rowSettings; color: "#2E2E38" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 120 }
                }
            }
        }
    }

    // ---- all-apps view ----
    Item {
        anchors.fill: parent
        visible: view === "all"

        Row {
            x: 32
            y: 66
            spacing: 10
            Text {
                text: qsTr("< Back")
                color: "#00F0FF"
                font.pixelSize: 13
                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                }
            }
            Text {
                text: qsTr("All apps")
                color: "#F2F2F2"
                font.pixelSize: 14
                font.bold: true
            }
        }

        Column {
            x: 32
            y: 110
            width: parent.width - 64
            spacing: 2

            Rectangle {
                width: 576
                height: 48
                radius: 8
                color: "transparent"
                Text {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Calculator")
                    color: "#F2F2F2"
                    font.pixelSize: 14
                }
                MouseArea {
                    id: allCalcMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            Rectangle {
                width: 576
                height: 48
                radius: 8
                color: "transparent"
                Text {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Files")
                    color: "#F2F2F2"
                    font.pixelSize: 14
                }
                MouseArea {
                    id: allFilesMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            Rectangle {
                width: 576
                height: 48
                radius: 8
                color: "transparent"
                visible: paintInstalled
                Text {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Helix Paint")
                    color: "#F2F2F2"
                    font.pixelSize: 14
                }
                MouseArea {
                    id: allPaintMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            Rectangle {
                width: 576
                height: 48
                radius: 8
                color: "transparent"
                Text {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Helix Store")
                    color: "#F2F2F2"
                    font.pixelSize: 14
                }
                MouseArea {
                    id: allStoreMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            Rectangle {
                width: 576
                height: 48
                radius: 8
                color: "transparent"
                Text {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Settings")
                    color: "#F2F2F2"
                    font.pixelSize: 14
                }
                MouseArea {
                    id: allSettingsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            Rectangle {
                width: 576
                height: 48
                radius: 8
                color: "transparent"
                Text {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Task Manager")
                    color: "#F2F2F2"
                    font.pixelSize: 14
                }
                MouseArea {
                    id: allTaskmgrMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            Rectangle {
                width: 576
                height: 48
                radius: 8
                color: "transparent"
                Text {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Terminal")
                    color: "#F2F2F2"
                    font.pixelSize: 14
                }
                MouseArea {
                    id: allTerminalMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }

    // user + power row
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 64
        radius: 12
        color: "#1C1C24"

        Rectangle {
            width: 36
            height: 36
            radius: 18
            x: 20
            anchors.verticalCenter: parent.verticalCenter
            color: "#00F0FF"
            Text {
                anchors.centerIn: parent
                text: userName.charAt(0).toUpperCase()
                color: "#04222A"
                font.pixelSize: 18
                font.bold: true
            }
        }
        Text {
            x: 66
            anchors.verticalCenter: parent.verticalCenter
            text: userName
            color: "#F2F2F2"
            font.pixelSize: 15
        }
        Rectangle {
            id: powerBtn
            width: 48
            height: 64
            anchors.right: parent.right
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("\u23FB")
                color: "#A8A8B0"
                font.pixelSize: 22
            }
            MouseArea {
                id: powerMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: powerMouseArea.containsMouse
                PropertyChanges { target: powerBtn; color: "#2E2E38" }
            }
            transitions: Transition {
                ColorAnimation { duration: 120 }
            }
        }
    }
}
