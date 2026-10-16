import QtQuick
import HelixShell

// HelixOS desktop icons: static column, hover-highlight only.
// Live behavior (open, select, drag) gets wired at packaging time.
Column {
    id: root
    spacing: 26

    property alias iconPcMouse: mousePC
    property alias iconBinMouse: mouseBin
    property alias iconWebMouse: mouseWeb
    property alias iconFilesMouse: mouseFiles

    Column {
        width: 96
        spacing: 6
        Rectangle {
            id: badgePC
            width: 56
            height: 56
            radius: 12
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#26262E"
            border.color: "#00F0FF"
            border.width: 0
            Text {
                anchors.centerIn: parent
                text: qsTr("PC")
                color: "#F2F2F2"
                font.pixelSize: 20
                font.bold: true
            }
            MouseArea {
                id: mousePC
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: mousePC.containsMouse
                PropertyChanges { target: badgePC; border.width: 2; color: "#2E2E38" }
            }
            transitions: Transition {
                ColorAnimation { duration: 140 }
                NumberAnimation { properties: "border.width"; duration: 140 }
            }
        }
        Text {
            width: 96
            text: qsTr("This PC")
            color: "white"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }

    Column {
        width: 96
        spacing: 6
        Rectangle {
            id: badgeBin
            width: 56
            height: 56
            radius: 12
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#26262E"
            border.color: "#00F0FF"
            border.width: 0
            Text {
                anchors.centerIn: parent
                text: qsTr("BIN")
                color: "#F2F2F2"
                font.pixelSize: 18
                font.bold: true
            }
            MouseArea {
                id: mouseBin
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: mouseBin.containsMouse
                PropertyChanges { target: badgeBin; border.width: 2; color: "#2E2E38" }
            }
            transitions: Transition {
                ColorAnimation { duration: 140 }
                NumberAnimation { properties: "border.width"; duration: 140 }
            }
        }
        Text {
            width: 96
            text: qsTr("Recycle Bin")
            color: "white"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }

    Column {
        width: 96
        spacing: 6
        Rectangle {
            id: badgeWeb
            width: 56
            height: 56
            radius: 12
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#26262E"
            border.color: "#00F0FF"
            border.width: 0
            Text {
                anchors.centerIn: parent
                text: qsTr("W")
                color: "#00F0FF"
                font.pixelSize: 24
                font.bold: true
            }
            MouseArea {
                id: mouseWeb
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: mouseWeb.containsMouse
                PropertyChanges { target: badgeWeb; border.width: 2; color: "#2E2E38" }
            }
            transitions: Transition {
                ColorAnimation { duration: 140 }
                NumberAnimation { properties: "border.width"; duration: 140 }
            }
        }
        Text {
            width: 96
            text: qsTr("Browser")
            color: "white"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }

    Column {
        width: 96
        spacing: 6
        Rectangle {
            id: badgeFiles
            width: 56
            height: 56
            radius: 12
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#26262E"
            border.color: "#00F0FF"
            border.width: 0
            Text {
                anchors.centerIn: parent
                text: qsTr("F")
                color: "#C6FF00"
                font.pixelSize: 24
                font.bold: true
            }
            MouseArea {
                id: mouseFiles
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: mouseFiles.containsMouse
                PropertyChanges { target: badgeFiles; border.width: 2; color: "#2E2E38" }
            }
            transitions: Transition {
                ColorAnimation { duration: 140 }
                NumberAnimation { properties: "border.width"; duration: 140 }
            }
        }
        Text {
            width: 96
            text: qsTr("Files")
            color: "white"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }
}
