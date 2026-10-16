import QtQuick
import QtQuick.Window

// HelixOS shell entry point: fullscreen desktop over whatever runs below.
Window {
    visible: true
    visibility: Window.FullScreen
    title: "HelixOS"

    Desktop {
        anchors.fill: parent
    }
}
