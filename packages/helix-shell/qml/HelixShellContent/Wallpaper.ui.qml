import QtQuick
import HelixShell

// HelixOS ambient wallpaper: deep-space gradient + slow drifting glows.
// Purely decorative life — no logic, safe to restyle freely.
Rectangle {
    id: root
    width: Constants.width
    height: Constants.height

    property int theme: 0
    property color glow: "#00F0FF"

    gradient: Gradient {
        GradientStop { position: 0.0; color: theme === 1 ? "#120B1E" : (theme === 2 ? "#0B1A12" : (theme === 3 ? "#1E0F0B" : "#0B0E1A")) }
        GradientStop { position: 0.55; color: theme === 1 ? "#1A0F2E" : (theme === 2 ? "#0F2E1A" : (theme === 3 ? "#2E1A0F" : "#101527")) }
        GradientStop { position: 1.0; color: theme === 1 ? "#2E0F33" : (theme === 2 ? "#0A3324" : (theme === 3 ? "#331A0A" : "#0A2A33")) }
    }

    Rectangle {
        id: orbA
        width: 520
        height: 520
        radius: 260
        color: glow
        opacity: 0.10
        x: 200
        y: 120

        SequentialAnimation on x {
            loops: Animation.Infinite
            NumberAnimation { to: 440; duration: 14000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 200; duration: 14000; easing.type: Easing.InOutSine }
        }
        SequentialAnimation on y {
            loops: Animation.Infinite
            NumberAnimation { to: 260; duration: 18000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 120; duration: 18000; easing.type: Easing.InOutSine }
        }
    }

    Rectangle {
        id: orbB
        width: 640
        height: 640
        radius: 320
        color: "#7A00FF"
        opacity: 0.08
        x: 1150
        y: 480

        SequentialAnimation on x {
            loops: Animation.Infinite
            NumberAnimation { to: 940; duration: 20000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1150; duration: 20000; easing.type: Easing.InOutSine }
        }
    }
}
