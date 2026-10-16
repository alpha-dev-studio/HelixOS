import QtQuick
import HelixShell

// HelixOS Files: sidebar + breadcrumb + folder grid + status bar.
Rectangle {
    id: win
    width: 900
    height: 560
    radius: 10
    color: "#26262E"
    border.color: "#3A3A46"
    border.width: 1
    clip: true

    property alias closeMouse: closeMouseArea
    property alias minMouse: minMouseArea
    property alias maxMouse: maxMouseArea
    property var files: []
    property var demoFiles: [{name: "Desktop", isdir: true}, {name: "Documents", isdir: true}, {name: "Downloads", isdir: true}, {name: "Music", isdir: true}, {name: "Pictures", isdir: true}, {name: "Videos", isdir: true}, {name: "Projects", isdir: true}, {name: "Shared", isdir: true}]
    property string crumb: "Home"

    signal folderOpened(string name)
    signal backRequested()

    Rectangle {
        height: 42
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: "#1C1C24"
        Rectangle {
            id: backBtn
            x: 8
            width: 30
            height: 42
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
            Text {
                anchors.centerIn: parent
                text: qsTr("<")
                color: "#A8A8B0"
                font.pixelSize: 16
                font.bold: true
            }
            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: backRequested()
            }
            states: State {
                name: "hover"
                when: backMouse.containsMouse
                PropertyChanges { target: backBtn; opacity: 0.85 }
            }
        }
        Text {
            x: 44
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Files — ") + crumb
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
        x: 0
        y: 42
        width: 190
        spacing: 2
        Repeater {
            model: ["Home", "Desktop", "Documents", "Downloads", "Music", "Pictures"]
            delegate: Rectangle {
                width: 190
                height: 44
                color: index === 0 ? "#2E2E38" : "transparent"
                Text {
                    x: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData
                    color: "#F2F2F2"
                    font.pixelSize: 14
                }
            }
        }
    }

    Text {
        x: 210
        y: 56
        text: qsTr("Home")
        color: "#A8A8B0"
        font.pixelSize: 13
    }

    Grid {
        x: 210
        y: 90
        columns: 4
        columnSpacing: 14
        rowSpacing: 14
            Repeater {
                model: files.length > 0 ? files : demoFiles
                delegate: Column {
                    width: 150
                    spacing: 6
                    Rectangle {
                        id: folderCard
                        width: 150
                        height: 104
                        radius: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#34343E"
                        Text {
                            anchors.centerIn: parent
                            text: modelData.isdir ? "\uD83D\uDCC1" : "\uD83D\uDCC4"
                            font.pixelSize: 40
                        }
                        MouseArea {
                            id: folderMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (modelData.isdir) {
                                    folderOpened(modelData.name);
                                }
                            }
                        }
                    states: State {
                        name: "hover"
                        when: folderMouse.containsMouse
                        PropertyChanges { target: folderCard; color: "#3E3E48" }
                    }
                    transitions: Transition {
                        ColorAnimation { duration: 130 }
                    }
                }
                    Text {
                        text: modelData.name
                        color: "#F2F2F2"
                        font.pixelSize: 13
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 30
        color: "#1C1C24"
        Text {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            text: (files.length > 0 ? files.length : 8) + " items"
            color: "#A8A8B0"
            font.pixelSize: 12
        }
    }
}
