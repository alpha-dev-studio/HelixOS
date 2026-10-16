import QtQuick
import HelixShell

// HelixOS lock screen: big live clock over dimmed wallpaper + sign-in card.
// Unlock is driven from Desktop.qml via signInMouse.
Rectangle {
    id: lock
    color: "#0B0E1A"
    opacity: 0.96

    property alias lockClockText: clockLabel.text
    property alias lockDateText: dateLabel.text
    property alias signInMouse: signInMouseArea
    property alias userLabel: userNameLabel.text
    property color accent: "#00F0FF"

    // faint glow echo of the desktop
    Rectangle {
        width: 640
        height: 640
        radius: 320
        color: "#00F0FF"
        opacity: 0.06
        anchors.centerIn: parent
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -120
        spacing: 4
        Text {
            id: clockLabel
            text: qsTr("12:00")
            color: "#F2F2F2"
            font.pixelSize: 96
            font.weight: Font.Light
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            id: dateLabel
            text: qsTr("Wednesday, October 15")
            color: "#A8A8B0"
            font.pixelSize: 22
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // sign-in card
    Column {
        width: 320
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 170
        spacing: 12

        Rectangle {
            width: 88
            height: 88
            radius: 44
            anchors.horizontalCenter: parent.horizontalCenter
            color: accent
            Text {
                anchors.centerIn: parent
                text: qsTr("H")
                color: "#04222A"
                font.pixelSize: 40
                font.bold: true
            }
        }
        Text {
            id: userNameLabel
            text: qsTr("helix")
            color: "#F2F2F2"
            font.pixelSize: 22
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Rectangle {
            width: 320
            height: 40
            radius: 8
            color: "#16161E"
            border.color: "#33333E"
            border.width: 1
            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                verticalAlignment: Text.AlignVCenter
                color: "#F2F2F2"
                font.pixelSize: 15
                echoMode: TextInput.Password
            }
            Text {
                x: 14
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Password")
                color: "#6E6E78"
                font.pixelSize: 15
                visible: passwordInput.text === ""
            }
        }
        Rectangle {
            id: signInBtn
            width: 320
            height: 42
            radius: 8
            anchors.horizontalCenter: parent.horizontalCenter
            color: accent
            Text {
                anchors.centerIn: parent
                text: qsTr("Sign in")
                color: "#04222A"
                font.pixelSize: 16
                font.bold: true
            }
            MouseArea {
                id: signInMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: [
                State {
                    name: "hover"
                    when: signInMouseArea.containsMouse && !signInMouseArea.pressed
                    PropertyChanges { target: signInBtn; color: "#33F5FF" }
                },
                State {
                    name: "pressed"
                    when: signInMouseArea.pressed
                    PropertyChanges { target: signInBtn; color: "#00C8D6" }
                }
            ]
            transitions: Transition {
                ColorAnimation { duration: 130 }
            }
        }
        Text {
            text: qsTr("Click Sign in to enter HelixOS")
            color: "#6E6E78"
            font.pixelSize: 13
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
