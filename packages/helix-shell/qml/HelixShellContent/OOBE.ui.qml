import QtQuick
import HelixShell

// HelixOS first-run wizard: Welcome -> Wi-Fi -> User -> Done.
// Step flow is driven from Desktop.qml.
Rectangle {
    id: oobe
    color: "#0B0E1A"

    property int step: 0
    property var networks: []
    property alias nextMouse: nextMouseArea
    property alias backMouse: backMouseArea
    property alias finishMouse: finishMouseArea

    Rectangle {
        width: 560
        height: 640
        radius: 14
        anchors.centerIn: parent
        y: -20
        color: "#26262E"
        border.color: "#3A3A46"
        border.width: 1

        // step dots
        Row {
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            Repeater {
                model: 4
                delegate: Rectangle {
                    width: 32
                    height: 6
                    radius: 3
                    color: index <= step ? "#00F0FF" : "#34343E"
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
            }
        }

        // step 0: welcome
        Column {
            anchors.centerIn: parent
            spacing: 14
            visible: step === 0
            Rectangle {
                width: 96
                height: 96
                radius: 22
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#00F0FF"
                Text {
                    anchors.centerIn: parent
                    text: qsTr("H")
                    color: "#04222A"
                    font.pixelSize: 52
                    font.bold: true
                }
            }
            Text {
                text: qsTr("Welcome to HelixOS")
                color: "#F2F2F2"
                font.pixelSize: 30
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: qsTr("Let's get your system set up in a minute.")
                color: "#A8A8B0"
                font.pixelSize: 15
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // step 1: wifi
        Column {
            x: 60
            y: 110
            width: parent.width - 120
            spacing: 10
            visible: step === 1
            Text {
                text: qsTr("Connect to Wi-Fi")
                color: "#F2F2F2"
                font.pixelSize: 26
                font.bold: true
            }
            Repeater {
                model: networks.length > 0 ? networks : [{ssid: "HomeNet", active: true}, {ssid: "CoffeeShop", active: false}, {ssid: "HelixHotspot", active: false}]
                delegate: Rectangle {
                    id: wifiRow
                    width: 440
                    height: 52
                    radius: 8
                    color: modelData.active ? "#2E2E38" : "transparent"
                    border.color: modelData.active ? "#00F0FF" : "#34343E"
                    border.width: 1
                    Text {
                        x: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.ssid
                        color: "#F2F2F2"
                        font.pixelSize: 15
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.active ? qsTr("Connected") : qsTr("")
                        color: "#00F0FF"
                        font.pixelSize: 13
                    }
                }
            }
        }

        // step 2: user
        Column {
            x: 60
            y: 110
            width: parent.width - 120
            spacing: 12
            visible: step === 2
            Text {
                text: qsTr("Who are you?")
                color: "#F2F2F2"
                font.pixelSize: 26
                font.bold: true
            }
            Text {
                text: qsTr("Your name")
                color: "#A8A8B0"
                font.pixelSize: 13
            }
            Rectangle {
                width: 440
                height: 44
                radius: 8
                color: "#16161E"
                border.color: "#33333E"
                border.width: 1
                TextInput {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: Text.AlignVCenter
                    color: "#F2F2F2"
                    font.pixelSize: 15
                }
            }
            Text {
                text: qsTr("Password")
                color: "#A8A8B0"
                font.pixelSize: 13
            }
            Rectangle {
                width: 440
                height: 44
                radius: 8
                color: "#16161E"
                border.color: "#33333E"
                border.width: 1
                TextInput {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: Text.AlignVCenter
                    color: "#F2F2F2"
                    font.pixelSize: 15
                    echoMode: TextInput.Password
                }
            }
        }

        // step 3: done
        Column {
            anchors.centerIn: parent
            spacing: 14
            visible: step === 3
            Text {
                text: qsTr("\u2713")
                color: "#00F0FF"
                font.pixelSize: 64
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: qsTr("You're all set")
                color: "#F2F2F2"
                font.pixelSize: 30
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: qsTr("Welcome to HelixOS.")
                color: "#A8A8B0"
                font.pixelSize: 15
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // nav buttons
        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12
            Rectangle {
                width: 130
                height: 42
                radius: 8
                color: "transparent"
                border.color: "#3A3A46"
                border.width: 1
                visible: step > 0 && step < 3
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Back")
                    color: "#F2F2F2"
                    font.pixelSize: 15
                }
                MouseArea {
                    id: backMouseArea
                    anchors.fill: parent
                }
            }
            Rectangle {
                id: nextBtn
                width: 130
                height: 42
                radius: 8
                color: "#00F0FF"
                visible: step < 3
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Next")
                    color: "#04222A"
                    font.pixelSize: 15
                    font.bold: true
                }
                MouseArea {
                    id: nextMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: nextMouseArea.containsMouse
                    PropertyChanges { target: nextBtn; color: "#33F5FF" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 130 }
                }
            }
            Rectangle {
                id: finishBtn
                width: 160
                height: 42
                radius: 8
                color: "#00F0FF"
                visible: step === 3
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Enter HelixOS")
                    color: "#04222A"
                    font.pixelSize: 15
                    font.bold: true
                }
                MouseArea {
                    id: finishMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: finishMouseArea.containsMouse
                    PropertyChanges { target: finishBtn; color: "#33F5FF" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 130 }
                }
            }
        }
    }
}
