// Theme.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property font defaultFont: Qt.font({
        family: "Noto Sans",
        pointSize: 12,
        bold: true
    })

    readonly property font workspaceFont: Qt.font({
        family: "Jetbrains Mono",
        pixelSize: 15,
        bold: true
    })

    readonly property color backgroundColor: "#11111B"
    readonly property color textColor: "#cdd6f4"
    readonly property color selectedTextColor: "#1e1e2e"
    readonly property color selectedColor: "#cba6f7"
    readonly property color hoverColor: "#585b70"
    readonly property color pressedColor: "#89b4fa"

    readonly property real barHeight: 36
    readonly property real sectionHorizontalPadding: 8
    readonly property real sectionVerticalPadding: 2
    readonly property real itemSpacing: 4
    readonly property real defaultRadius: 12
    readonly property real defaultBackgroundHeight: 24
}
