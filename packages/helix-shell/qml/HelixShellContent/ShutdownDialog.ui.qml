import QtQuick
import HelixShell

// HelixOS power dialog: Sleep / Restart / Shut down + Cancel.
// Actions only dismiss for now; real power calls wire up at packaging.
Rectangle {
    id: dlg
    width: 340
    height: 300
    radius: 12
    color: "#F226262E"
    border.color: "#3A3A46"
    border.width: 1

    property alias sleepMouse: sleepMouseArea
    property alias restartMouse: restartMouseArea
    property alias shutMouse: shutMouseArea
    property alias cancelMouse: cancelMouseArea

    property bool open: false

    opacity: open ? 1.0 : 0.0
    visible: opacity > 0.0

    Behavior on opacity {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    Text {
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Power")
        color: "#F2F2F2"
        font.pixelSize: 20
        font.bold: true
    }

    Row {
        anchors.centerIn: parent
        spacing: 14

        Column {
            spacing: 8
            Rectangle {
                id: sleepBtn
                width: 88
                height: 88
                radius: 12
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#34343E"
                Text {
                    anchors.centerIn: parent
                    text: qsTr("\u263E")
                    color: "#F2F2F2"
                    font.pixelSize: 34
                }
                MouseArea {
                    id: sleepMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: sleepMouseArea.containsMouse
                    PropertyChanges { target: sleepBtn; color: "#3E3E48" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 130 }
                }
            }
            Text {
                text: qsTr("Sleep")
                color: "#F2F2F2"
                font.pixelSize: 13
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Column {
            spacing: 8
            Rectangle {
                id: restartBtn
                width: 88
                height: 88
                radius: 12
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#34343E"
                Text {
                    anchors.centerIn: parent
                    text: qsTr("\u27F3")
                    color: "#F2F2F2"
                    font.pixelSize: 34
                }
                MouseArea {
                    id: restartMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: restartMouseArea.containsMouse
                    PropertyChanges { target: restartBtn; color: "#3E3E48" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 130 }
                }
            }
            Text {
                text: qsTr("Restart")
                color: "#F2F2F2"
                font.pixelSize: 13
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Column {
            spacing: 8
            Rectangle {
                id: shutBtn
                width: 88
                height: 88
                radius: 12
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#34343E"
                Text {
                    anchors.centerIn: parent
                    text: qsTr("\u23FB")
                    color: "#F2F2F2"
                    font.pixelSize: 34
                }
                MouseArea {
                    id: shutMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: shutMouseArea.containsMouse
                    PropertyChanges { target: shutBtn; color: "#3E3E48" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 130 }
                }
            }
            Text {
                text: qsTr("Shut down")
                color: "#F2F2F2"
                font.pixelSize: 13
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Cancel")
        color: "#00F0FF"
        font.pixelSize: 14
        MouseArea {
            id: cancelMouseArea
            anchors.fill: parent
        }
    }
}
