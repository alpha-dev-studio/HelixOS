import QtQuick
import QtQuick.Controls
import HelixShell

// HelixOS Settings: sidebar navigation + real pages.
// Page switching and toggles are driven from Desktop.qml.
Rectangle {
    id: win
    width: 920
    height: 600
    radius: 10
    color: "#26262E"
    border.color: "#3A3A46"
    border.width: 1
    clip: true

    property string page: "wifi"
    property bool wifiOn: true
    property bool btOn: false
    property color accent: "#00F0FF"
    property int wallpaperTheme: 0
    property string userName: "helix"
    property bool updatesChecked: false
    property string taskAlign: "center"
    property var networks: []
    property var resolutions: ["1920 x 1080", "1600 x 900", "1366 x 768", "1280 x 720"]
    property real brightLevel: 0.8
    property real volLevel: 0.6
    property string battLine: "Battery: 82% — discharging"
    property string updatesText: "Check for HelixOS system updates."
    property alias closeMouse: closeMouseArea
    property alias minMouse: minMouseArea
    property alias maxMouse: maxMouseArea
    property alias sideWifiMouse: sideWifiMouseArea
    property alias sideBtMouse: sideBtMouseArea
    property alias sideDisplayMouse: sideDisplayMouseArea
    property alias sideSoundMouse: sideSoundMouseArea
    property alias sidePowerMouse: sidePowerMouseArea
    property alias sidePersonalMouse: sidePersonalMouseArea
    property alias sideAccountsMouse: sideAccountsMouseArea
    property alias sideAppsMouse: sideAppsMouseArea
    property alias sideUpdatesMouse: sideUpdatesMouseArea
    property alias sideAboutMouse: sideAboutMouseArea
    property alias wifiToggleMouse: wifiToggleMouseArea
    property alias btToggleMouse: btToggleMouseArea
    property alias sw0Mouse: sw0MouseArea
    property alias sw1Mouse: sw1MouseArea
    property alias sw2Mouse: sw2MouseArea
    property alias sw3Mouse: sw3MouseArea
    property alias ac0Mouse: ac0MouseArea
    property alias ac1Mouse: ac1MouseArea
    property alias ac2Mouse: ac2MouseArea
    property alias saveNameMouse: saveNameMouseArea
    property alias userNameField: nameInput.text
    property alias checkUpdatesMouse: checkUpdatesMouseArea
    property alias alignCenterMouse: alignCenterMouseArea
    property alias alignLeftMouse: alignLeftMouseArea
    property alias brightSlider: brightSliderItem
    property alias volSlider: volSliderItem
    property alias resCombo: resComboBox

    Rectangle {
        height: 42
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: "#1C1C24"
        Text {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Settings")
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

    // sidebar
    Column {
        x: 0
        y: 42
        width: 220
        height: parent.height - 42
        spacing: 2

        Rectangle {
            id: sideWifi
            width: 220
            height: 48
            color: page === "wifi" ? "#2E2E38" : "transparent"
            Text {
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Wi-Fi")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: sideWifiMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        Rectangle {
            id: sideBt
            width: 220
            height: 48
            color: page === "bt" ? "#2E2E38" : "transparent"
            Text {
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Bluetooth")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: sideBtMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        Rectangle {
            id: sideDisplay
            width: 220
            height: 48
            color: page === "display" ? "#2E2E38" : "transparent"
            Text {
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Display")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: sideDisplayMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        Rectangle {
            id: sideSound
            width: 220
            height: 48
            color: page === "sound" ? "#2E2E38" : "transparent"
            Text {
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Sound")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: sideSoundMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        Rectangle {
            id: sidePower
            width: 220
            height: 48
            color: page === "power" ? "#2E2E38" : "transparent"
            Text {
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Power")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: sidePowerMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        Rectangle {
            id: sidePersonal
            width: 220
            height: 48
            color: page === "personal" ? "#2E2E38" : "transparent"
            Text {
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Personalisation")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: sidePersonalMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        Rectangle {
            id: sideAccounts
            width: 220
            height: 48
            color: page === "accounts" ? "#2E2E38" : "transparent"
            Text {
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Accounts")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: sideAccountsMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        Rectangle {
            id: sideApps
            width: 220
            height: 48
            color: page === "apps" ? "#2E2E38" : "transparent"
            Text {
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Apps")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: sideAppsMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        Rectangle {
            id: sideUpdates
            width: 220
            height: 48
            color: page === "updates" ? "#2E2E38" : "transparent"
            Text {
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Updates")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: sideUpdatesMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        Rectangle {
            id: sideAbout
            width: 220
            height: 48
            color: page === "about" ? "#2E2E38" : "transparent"
            Text {
                x: 20
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("About")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            MouseArea {
                id: sideAboutMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }

    // pages
    Item {
        x: 240
        y: 62
        width: parent.width - 260
        height: parent.height - 82

        Column {
            spacing: 10
            visible: page === "wifi"
            Row {
                spacing: 12
                Text {
                    text: qsTr("Wi-Fi")
                    color: "#F2F2F2"
                    font.pixelSize: 20
                    font.bold: true
                }
                Rectangle {
                    id: wifiSwitch
                    width: 52
                    height: 28
                    radius: 14
                    anchors.verticalCenter: parent.verticalCenter
                    color: wifiOn ? accent : "#34343E"
                    Rectangle {
                        width: 22
                        height: 22
                        radius: 11
                        x: wifiOn ? 27 : 3
                        y: 3
                        color: "white"
                        Behavior on x {
                            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                        }
                    }
                    MouseArea {
                        id: wifiToggleMouseArea
                        anchors.fill: parent
                    }
                }
            }
            Repeater {
                model: networks.length > 0 ? networks : [{ssid: "HomeNet", active: true, demo: true}, {ssid: "CoffeeShop", active: false, demo: true}, {ssid: "HelixHotspot", active: false, demo: true}]
                delegate: Rectangle {
                    width: 420
                    height: 48
                    radius: 8
                    color: "#34343E"
                    Text {
                        x: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.ssid + (modelData.active ? " — Connected" : "")
                        color: "#F2F2F2"
                        font.pixelSize: 14
                    }
                }
            }
        }

        Column {
            spacing: 10
            visible: page === "bt"
            Row {
                spacing: 12
                Text {
                    text: qsTr("Bluetooth")
                    color: "#F2F2F2"
                    font.pixelSize: 20
                    font.bold: true
                }
                Rectangle {
                    id: btSwitch
                    width: 52
                    height: 28
                    radius: 14
                    anchors.verticalCenter: parent.verticalCenter
                    color: btOn ? accent : "#34343E"
                    Rectangle {
                        width: 22
                        height: 22
                        radius: 11
                        x: btOn ? 27 : 3
                        y: 3
                        color: "white"
                        Behavior on x {
                            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                        }
                    }
                    MouseArea {
                        id: btToggleMouseArea
                        anchors.fill: parent
                    }
                }
            }
            Text {
                text: btOn ? qsTr("Searching for devices...") : qsTr("Bluetooth is off.")
                color: "#A8A8B0"
                font.pixelSize: 14
            }
        }

        Column {
            spacing: 12
            visible: page === "display"
            Text {
                text: qsTr("Display")
                color: "#F2F2F2"
                font.pixelSize: 20
                font.bold: true
            }
            Text {
                text: qsTr("Brightness")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            Slider {
                id: brightSliderItem
                width: 420
                value: brightLevel
            }
            Text {
                text: qsTr("Resolution")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            ComboBox {
                id: resComboBox
                width: 420
                model: resolutions
            }
        }

        Column {
            spacing: 12
            visible: page === "sound"
            Text {
                text: qsTr("Sound")
                color: "#F2F2F2"
                font.pixelSize: 20
                font.bold: true
            }
            Text {
                text: qsTr("Output volume")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            Slider {
                id: volSliderItem
                width: 420
                value: volLevel
            }
            Text {
                text: qsTr("Output: Built-in speakers")
                color: "#A8A8B0"
                font.pixelSize: 14
            }
        }

        Column {
            spacing: 12
            visible: page === "power"
            Text {
                text: qsTr("Power")
                color: "#F2F2F2"
                font.pixelSize: 20
                font.bold: true
            }
            Text {
                text: battLine
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            RadioButton {
                text: qsTr("Balanced")
                checked: true
            }
            RadioButton {
                text: qsTr("Performance")
            }
            RadioButton {
                text: qsTr("Power saver")
            }
        }

        Column {
            spacing: 10
            visible: page === "about"
            Rectangle {
                width: 72
                height: 72
                radius: 16
                color: "#00F0FF"
                Text {
                    anchors.centerIn: parent
                    text: qsTr("H")
                    color: "#04222A"
                    font.pixelSize: 36
                    font.bold: true
                }
            }
            Text {
                text: qsTr("HelixOS 1.0 Surge")
                color: "#F2F2F2"
                font.pixelSize: 22
                font.bold: true
            }
            Text {
                text: qsTr("Helix shell 1.0 — Debian 13 trixie base")
                color: "#A8A8B0"
                font.pixelSize: 14
            }
            Text {
                text: qsTr("64-bit UEFI/BIOS — 4 GB RAM minimum")
                color: "#A8A8B0"
                font.pixelSize: 14
            }
        }

        Column {
            spacing: 12
            visible: page === "personal"
            Text {
                text: qsTr("Personalisation")
                color: "#F2F2F2"
                font.pixelSize: 20
                font.bold: true
            }
            Text {
                text: qsTr("Wallpaper")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            Row {
                spacing: 10
                Rectangle {
                    width: 96
                    height: 60
                    radius: 8
                    color: "#101527"
                    border.color: "white"
                    border.width: wallpaperTheme === 0 ? 3 : 0
                    MouseArea {
                        id: sw0MouseArea
                        anchors.fill: parent
                    }
                }
                Rectangle {
                    width: 96
                    height: 60
                    radius: 8
                    color: "#1A0F2E"
                    border.color: "white"
                    border.width: wallpaperTheme === 1 ? 3 : 0
                    MouseArea {
                        id: sw1MouseArea
                        anchors.fill: parent
                    }
                }
                Rectangle {
                    width: 96
                    height: 60
                    radius: 8
                    color: "#0F2E1A"
                    border.color: "white"
                    border.width: wallpaperTheme === 2 ? 3 : 0
                    MouseArea {
                        id: sw2MouseArea
                        anchors.fill: parent
                    }
                }
                Rectangle {
                    width: 96
                    height: 60
                    radius: 8
                    color: "#2E1A0F"
                    border.color: "white"
                    border.width: wallpaperTheme === 3 ? 3 : 0
                    MouseArea {
                        id: sw3MouseArea
                        anchors.fill: parent
                    }
                }
            }
            Text {
                text: qsTr("Accent color")
                color: "#F2F2F2"
                font.pixelSize: 14
            }            Row {
                spacing: 10
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: "#00F0FF"
                    border.color: "white"
                    border.width: accent == "#00F0FF" ? 3 : 0
                    MouseArea {
                        id: ac0MouseArea
                        anchors.fill: parent
                    }
                }
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: "#C6FF00"
                    border.color: "white"
                    border.width: accent == "#C6FF00" ? 3 : 0
                    MouseArea {
                        id: ac1MouseArea
                        anchors.fill: parent
                    }
                }
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: "#B44DFF"
                    border.color: "white"
                    border.width: accent == "#B44DFF" ? 3 : 0
                    MouseArea {
                        id: ac2MouseArea
                        anchors.fill: parent
                    }
                }
            }
            Text {
                text: qsTr("Taskbar alignment")
                color: "#F2F2F2"
                font.pixelSize: 14
            }
            Row {
                spacing: 10
                Rectangle {
                    width: 130
                    height: 42
                    radius: 8
                    color: "#16161E"
                    border.color: taskAlign === "center" ? accent : "#33333E"
                    border.width: taskAlign === "center" ? 2 : 1
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Center")
                        color: "#F2F2F2"
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: alignCenterMouseArea
                        anchors.fill: parent
                    }
                }
                Rectangle {
                    width: 130
                    height: 42
                    radius: 8
                    color: "#16161E"
                    border.color: taskAlign === "left" ? accent : "#33333E"
                    border.width: taskAlign === "left" ? 2 : 1
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Left")
                        color: "#F2F2F2"
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: alignLeftMouseArea
                        anchors.fill: parent
                    }
                }
            }
        }

        Column {
            spacing: 12
            visible: page === "accounts"
            Text {
                text: qsTr("Accounts")
                color: "#F2F2F2"
                font.pixelSize: 20
                font.bold: true
            }
            Rectangle {
                width: 64
                height: 64
                radius: 32
                color: accent
                Text {
                    anchors.centerIn: parent
                    text: userName.charAt(0).toUpperCase()
                    color: "#04222A"
                    font.pixelSize: 28
                    font.bold: true
                }
            }
            Text {
                text: qsTr("Display name")
                color: "#A8A8B0"
                font.pixelSize: 13
            }
            Row {
                spacing: 10
                Rectangle {
                    width: 300
                    height: 44
                    radius: 8
                    color: "#16161E"
                    border.color: "#33333E"
                    border.width: 1
                    TextInput {
                        id: nameInput
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        verticalAlignment: Text.AlignVCenter
                        color: "#F2F2F2"
                        font.pixelSize: 15
                    }
                }
                Rectangle {
                    id: saveNameBtn
                    width: 110
                    height: 44
                    radius: 8
                    color: accent
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Save")
                        color: "#04222A"
                        font.pixelSize: 15
                        font.bold: true
                    }
                    MouseArea {
                        id: saveNameMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    states: State {
                        name: "hover"
                        when: saveNameMouseArea.containsMouse
                        PropertyChanges { target: saveNameBtn; opacity: 0.85 }
                    }
                    transitions: Transition {
                        NumberAnimation { properties: "opacity"; duration: 130 }
                    }
                }
            }
            Text {
                text: qsTr("Signed in as ") + userName
                color: "#A8A8B0"
                font.pixelSize: 14
            }
        }

        Column {
            spacing: 8
            visible: page === "apps"
            Text {
                text: qsTr("Apps")
                color: "#F2F2F2"
                font.pixelSize: 20
                font.bold: true
            }
            Text {
                text: qsTr("Installed apps are managed by Helix Store.")
                color: "#A8A8B0"
                font.pixelSize: 14
            }
            Repeater {
                model: ListModel {
                    ListElement { app: "Helix Store"; size: "48 MB" }
                    ListElement { app: "Files"; size: "22 MB" }
                    ListElement { app: "Terminal"; size: "9 MB" }
                    ListElement { app: "Calculator"; size: "4 MB" }
                    ListElement { app: "Helix Paint"; size: "12 MB" }
                }
                delegate: Rectangle {
                    width: 420
                    height: 48
                    radius: 8
                    color: "#34343E"
                    Text {
                        x: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: app
                        color: "#F2F2F2"
                        font.pixelSize: 14
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: size
                        color: "#A8A8B0"
                        font.pixelSize: 13
                    }
                }
            }
        }

        Column {
            spacing: 12
            visible: page === "updates"
            Text {
                text: qsTr("Updates")
                color: "#F2F2F2"
                font.pixelSize: 20
                font.bold: true
            }
            Text {
                text: updatesText
                color: "#A8A8B0"
                font.pixelSize: 14
            }
            Rectangle {
                id: checkBtn
                width: 170
                height: 42
                radius: 8
                color: accent
                Text {
                    anchors.centerIn: parent
                    text: qsTr("Check for updates")
                    color: "#04222A"
                    font.pixelSize: 15
                    font.bold: true
                }
                MouseArea {
                    id: checkUpdatesMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: checkUpdatesMouseArea.containsMouse
                    PropertyChanges { target: checkBtn; opacity: 0.85 }
                }
                transitions: Transition {
                    NumberAnimation { properties: "opacity"; duration: 130 }
                }
            }
        }
    }
}
