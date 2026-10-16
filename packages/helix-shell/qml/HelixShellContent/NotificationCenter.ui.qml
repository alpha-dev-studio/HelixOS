import QtQuick
import QtQuick.Controls
import HelixShell

// HelixOS notification center: quick toggles + brightness + notifications.
// Toggle states and Clear-all are driven from Desktop.qml.
Rectangle {
    id: center
    width: 380
    height: 640
    radius: 12
    color: "#F226262E"
    border.color: "#3A3A46"
    border.width: 1

    property bool open: false
    property bool wifiOn: true
    property bool btOn: false
    property bool nightOn: false
    property bool cleared: false
    property real brightLevel: 0.8
    property alias wifiMouse: wifiMouseArea
    property alias btMouse: btMouseArea
    property alias nightMouse: nightMouseArea
    property alias clearMouse: clearMouseArea
    property alias brightSlider: brightSliderItem

    opacity: open ? 1.0 : 0.0
    visible: opacity > 0.0

    Behavior on opacity {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    Text {
        x: 20
        y: 16
        text: qsTr("Quick settings")
        color: "#F2F2F2"
        font.pixelSize: 15
        font.bold: true
    }

    Row {
        x: 20
        y: 48
        spacing: 10

        Column {
            spacing: 6
            Rectangle {
                id: wifiTile
                width: 106
                height: 64
                radius: 10
                color: wifiOn ? "#00F0FF" : "#34343E"
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Wi-Fi")
                    color: wifiOn ? "#04222A" : "#F2F2F2"
                    font.pixelSize: 14
                    font.bold: true
                }
                MouseArea {
                    id: wifiMouseArea
                    anchors.fill: parent
                }
            }
            Text {
                text: wifiOn ? qsTr("HomeNet") : qsTr("Off")
                color: "#A8A8B0"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Column {
            spacing: 6
            Rectangle {
                id: btTile
                width: 106
                height: 64
                radius: 10
                color: btOn ? "#00F0FF" : "#34343E"
                Text {
                    anchors.centerIn: parent
                    text: qsTr("BT")
                    color: btOn ? "#04222A" : "#F2F2F2"
                    font.pixelSize: 14
                    font.bold: true
                }
                MouseArea {
                    id: btMouseArea
                    anchors.fill: parent
                }
            }
            Text {
                text: btOn ? qsTr("On") : qsTr("Off")
                color: "#A8A8B0"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Column {
            spacing: 6
            Rectangle {
                id: nightTile
                width: 106
                height: 64
                radius: 10
                color: nightOn ? "#00F0FF" : "#34343E"
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Night")
                    color: nightOn ? "#04222A" : "#F2F2F2"
                    font.pixelSize: 14
                    font.bold: true
                }
                MouseArea {
                    id: nightMouseArea
                    anchors.fill: parent
                }
            }
            Text {
                text: nightOn ? qsTr("On") : qsTr("Off")
                color: "#A8A8B0"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Text {
        x: 20
        y: 168
        text: qsTr("Brightness")
        color: "#F2F2F2"
        font.pixelSize: 13
    }
    Slider {
        id: brightSliderItem
        x: 20
        y: 190
        width: parent.width - 40
        value: brightLevel
    }

    Row {
        x: 20
        y: 244
        width: parent.width - 40
        Text {
            text: qsTr("Notifications")
            color: "#F2F2F2"
            font.pixelSize: 15
            font.bold: true
        }
        Item {
            width: 1
            height: 1
        }
        Text {
            text: qsTr("Clear all")
            color: "#00F0FF"
            font.pixelSize: 13
            MouseArea {
                id: clearMouseArea
                anchors.fill: parent
            }
        }
    }

    Column {
        x: 20
        y: 278
        width: parent.width - 40
        spacing: 8
        visible: !cleared

        Repeater {
            model: ListModel {
                ListElement { glyph: "U"; title: "HelixOS Updater"; body: "System is up to date." }
                ListElement { glyph: "W"; title: "Welcome"; body: "Thanks for trying HelixOS." }
                ListElement { glyph: "B"; title: "Battery"; body: "82% remaining." }
            }
            delegate: Rectangle {
                width: 340
                height: 72
                radius: 10
                color: "#34343E"
                Rectangle {
                    x: 12
                    width: 34
                    height: 34
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 8
                    color: "#2E2E38"
                    Text {
                        anchors.centerIn: parent
                        text: glyph
                        color: "#00F0FF"
                        font.pixelSize: 15
                        font.bold: true
                    }
                }
                Text {
                    x: 56
                    y: 12
                    text: title
                    color: "#F2F2F2"
                    font.pixelSize: 13
                    font.bold: true
                }
                Text {
                    x: 56
                    y: 34
                    width: 270
                    text: body
                    color: "#A8A8B0"
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    Text {
        x: 20
        y: 278
        text: qsTr("All caught up.")
        color: "#6E6E78"
        font.pixelSize: 13
        visible: cleared
    }
}
