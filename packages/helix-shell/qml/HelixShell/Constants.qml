pragma Singleton
import QtQuick

// HelixOS shell constants (runtime-clean: no Design Studio modules,
// so this loads under plain Qt on the OS as well as in preview).
QtObject {
    readonly property int width: 1920
    readonly property int height: 1080

    readonly property font font: Qt.font({
        family: Qt.application.font.family,
        pixelSize: Qt.application.font.pixelSize
    })
    readonly property font largeFont: Qt.font({
        family: Qt.application.font.family,
        pixelSize: Qt.application.font.pixelSize * 1.6
    })

    readonly property color backgroundColor: "#0B0E1A"
}
