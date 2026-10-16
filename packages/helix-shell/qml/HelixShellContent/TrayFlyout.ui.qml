import QtQuick
import QtQuick.Controls
import HelixShell

// HelixOS tray flyout: quick hardware rows. Toggles and the
// Notifications jump are driven from Desktop.qml.
Rectangle {
    id: fly
    width: 340
    height: 330
    radius: 12
    color: "#F226262E"
    border.color: "#3A3A46"
    border.width: 1

    property bool open: false
    property bool wifiOn: true
    property real volLevel: 0.6
    property real brightLevel: 0.8
    property string battPct: "82%"
    property string battDetail: "Battery — 3h 12m left"
    property alias wifiMouse: wifiMouseArea
    property alias notifBtnMouse: notifBtnMouseArea
    property alias volSlider: volSliderItem
    property alias brightSlider: brightSliderItem

    opacity: open ? 1.0 : 0.0
    visible: opacity > 0.0

    Behavior on opacity {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    Column {
        x: 20
        y: 18
        width: parent.width - 40
        spacing: 14

        Row {
            spacing: 12
            Rectangle {
                width: 40
                height: 40
                radius: 10
                color: wifiOn ? "#00F0FF" : "#34343E"
                Text {
                    anchors.centerIn: parent
                    text: qsTr("W")
                    color: wifiOn ? "#04222A" : "#F2F2F2"
                    font.pixelSize: 16
                    font.bold: true
                }
                MouseArea {
                    id: wifiMouseArea
                    anchors.fill: parent
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: qsTr("Wi-Fi")
                    color: "#F2F2F2"
                    font.pixelSize: 14
                    font.bold: true
                }
                Text {
                    text: wifiOn ? qsTr("HomeNet") : qsTr("Off")
                    color: "#A8A8B0"
                    font.pixelSize: 12
                }
            }
        }

        Column {
            spacing: 4
            Text {
                text: qsTr("Volume")
                color: "#F2F2F2"
                font.pixelSize: 13
            }
            Slider {
                id: volSliderItem
                width: 300
                value: volLevel
            }
        }

        Column {
            spacing: 4
            Text {
                text: qsTr("Brightness")
                color: "#F2F2F2"
                font.pixelSize: 13
            }
            Slider {
                id: brightSliderItem
                width: 300
                value: brightLevel
            }
        }

        Row {
            spacing: 12
            Rectangle {
                width: 40
                height: 40
                radius: 10
                color: "#34343E"
                Text {
                    anchors.centerIn: parent
                    text: battPct
                    color: "#00F0FF"
                    font.pixelSize: 11
                    font.bold: true
                }
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: battDetail
                color: "#F2F2F2"
                font.pixelSize: 13
            }
        }

        Rectangle {
            id: notifBtn
            width: 300
            height: 40
            radius: 8
            color: "#34343E"
            Text {
                anchors.centerIn: parent
                text: qsTr("Notifications  >")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: notifBtnMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
            states: State {
                name: "hover"
                when: notifBtnMouseArea.containsMouse
                PropertyChanges { target: notifBtn; color: "#3E3E48" }
            }
            transitions: Transition {
                ColorAnimation { duration: 130 }
            }
        }
    }
}
