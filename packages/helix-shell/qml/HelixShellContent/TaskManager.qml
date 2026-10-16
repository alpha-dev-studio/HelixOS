import QtQuick
import QtQuick.Controls
import HelixShell

// HelixOS Task Manager: live-feel meters (ambient animation) + process list.
Rectangle {
    id: win
    width: 760
    height: 540
    radius: 10
    color: "#26262E"
    border.color: "#3A3A46"
    border.width: 1
    clip: true

    property alias closeMouse: closeMouseArea
    property alias minMouse: minMouseArea
    property alias maxMouse: maxMouseArea
    property var procs: []
    property var demoProcs: [{proc: "helix-shell", cpu: "12.4%", mem: "412 MB"}, {proc: "helix-updater", cpu: "4.1%", mem: "96 MB"}, {proc: "kwin_wayland", cpu: "8.8%", mem: "388 MB"}, {proc: "firefox", cpu: "3.2%", mem: "512 MB"}, {proc: "pipewire", cpu: "0.6%", mem: "24 MB"}, {proc: "Discover", cpu: "0.2%", mem: "141 MB"}]

    Rectangle {
        height: 42
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: "#1C1C24"
        Text {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Task Manager")
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

    Row {
        x: 24
        y: 62
        spacing: 24

        Column {
            spacing: 6
            Text {
                text: qsTr("CPU 34%")
                color: "#F2F2F2"
                font.pixelSize: 14
                font.bold: true
            }
            ProgressBar {
                width: 200
                SequentialAnimation on value {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.52; duration: 2600; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.21; duration: 3200; easing.type: Easing.InOutSine }
                }
            }
        }
        Column {
            spacing: 6
            Text {
                text: qsTr("Memory 61%")
                color: "#F2F2F2"
                font.pixelSize: 14
                font.bold: true
            }
            ProgressBar {
                width: 200
                SequentialAnimation on value {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.68; duration: 4100; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.55; duration: 3700; easing.type: Easing.InOutSine }
                }
            }
        }
        Column {
            spacing: 6
            Text {
                text: qsTr("Disk 12%")
                color: "#F2F2F2"
                font.pixelSize: 14
                font.bold: true
            }
            ProgressBar {
                width: 200
                SequentialAnimation on value {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.18; duration: 5200; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.09; duration: 4800; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    Row {
        x: 24
        y: 160
        width: parent.width - 48
        Text {
            width: 320
            text: qsTr("Process")
            color: "#6E6E78"
            font.pixelSize: 12
            font.bold: true
        }
        Text {
            width: 120
            text: qsTr("CPU")
            color: "#6E6E78"
            font.pixelSize: 12
            font.bold: true
        }
        Text {
            width: 120
            text: qsTr("Memory")
            color: "#6E6E78"
            font.pixelSize: 12
            font.bold: true
        }
    }

    Column {
        x: 24
        y: 186
        spacing: 4
            Repeater {
                model: procs.length > 0 ? procs : demoProcs
            delegate: Rectangle {
                id: procRow
                width: 712
                height: 44
                radius: 8
                color: "transparent"
                Text {
                    x: 8
                    width: 312
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.proc
                    color: "#F2F2F2"
                    font.pixelSize: 14
                }
                Text {
                    x: 328
                    width: 120
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.cpu
                    color: "#A8A8B0"
                    font.pixelSize: 13
                }
                Text {
                    x: 448
                    width: 120
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.mem
                    color: "#A8A8B0"
                    font.pixelSize: 13
                }
                Rectangle {
                    x: 600
                    width: 100
                    height: 30
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 6
                    color: "#34343E"
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("End task")
                        color: "#F2F2F2"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: endMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (typeof Helix !== "undefined" && Helix) {
                                Helix.killPid(modelData.pid);
                            }
                        }
                    }
                    states: State {
                        name: "hover"
                        when: endMouse.containsMouse
                        PropertyChanges { target: procRow; color: "#2E2E38" }
                    }
                    transitions: Transition {
                        ColorAnimation { duration: 120 }
                    }
                }
                MouseArea {
                    id: rowHover
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }
            }
        }
    }
}
