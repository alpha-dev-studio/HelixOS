import QtQuick
import HelixShell

// HelixOS desktop right-click menu. Shown/dismissed from Desktop.qml.
Rectangle {
    id: ctx
    width: 220
    height: 176
    radius: 10
    color: "#F226262E"
    border.color: "#3A3A46"
    border.width: 1

    property bool shown: false
    opacity: shown ? 1.0 : 0.0
    visible: opacity > 0.0

    Behavior on opacity {
        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 2
        Repeater {
            model: ["View", "Sort by", "Refresh", "Personalize"]
            delegate: Rectangle {
                id: ctxItem
                width: 208
                height: 40
                radius: 6
                color: "transparent"
                Text {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData
                    color: "#F2F2F2"
                    font.pixelSize: 13
                }
                MouseArea {
                    id: ctxMouse
                    anchors.fill: parent
                    hoverEnabled: true
                }
                states: State {
                    name: "hover"
                    when: ctxMouse.containsMouse
                    PropertyChanges { target: ctxItem; color: "#2E2E38" }
                }
                transitions: Transition {
                    ColorAnimation { duration: 110 }
                }
            }
        }
    }
}
