import QtQuick
import QtQuick.Controls.Basic
import "../.."
import "../../Systems" as Systems

Item {
    id: root

    property alias expanded: toggle.checked

    implicitWidth: reveal.width + toggle.implicitWidth
    implicitHeight: toggle.implicitHeight
    Keys.onEscapePressed: expanded = false

    Item {
        id: reveal
        property real progress: root.expanded ? 1 : 0

        anchors.right: toggle.left
        anchors.verticalCenter: parent.verticalCenter
        width: metrics.implicitWidth * progress
        height: metrics.implicitHeight
        clip: true
        visible: width > 0
        enabled: root.expanded && !revealAnimation.running

        Behavior on progress {
            NumberAnimation {
                id: revealAnimation
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Row {
            id: metrics
            anchors.right: parent.right
            spacing: Theme.itemSpacing

            ResourceMetric {
                text: Systems.Resources.cpuPercent === null ? "CPU N/A"
                    : "CPU " + Math.round(Systems.Resources.cpuPercent) + "%"
                tooltip: "CPU usage (logical)\n" + (Systems.Resources.cores.length
                    ? Systems.Resources.cores.map(core => core.name.toUpperCase() + ": "
                        + (core.percent === null ? "Sampling…" : Math.round(core.percent) + "%")).join("\n")
                    : "Unavailable")
                tooltipsEnabled: reveal.enabled
            }

            ResourceMetric {
                text: Systems.Resources.temperatures === null ? "Temp N/A"
                    : Math.round(Systems.Resources.temperatures.temperature) + "°C"
                tooltip: Systems.Resources.temperatures === null ? "CPU temperature sensors unavailable"
                    : Systems.Resources.temperatures.readings.map(reading =>
                        reading.name + ": " + reading.value.toFixed(1) + "°C").join("\n")
                tooltipsEnabled: reveal.enabled
            }

            ResourceMetric {
                text: Systems.Resources.memory === null ? "RAM N/A"
                    : "RAM " + Systems.Resources.memory.used.toFixed(1) + " GiB · "
                        + Math.round(Systems.Resources.memory.percent) + "%"
                tooltip: Systems.Resources.memory === null ? "Memory information unavailable"
                    : "RAM: " + Systems.Resources.memory.used.toFixed(1) + " / "
                        + Systems.Resources.memory.total.toFixed(1) + " GiB\n"
                        + "Usage: " + Math.round(Systems.Resources.memory.percent) + "%"
                tooltipsEnabled: reveal.enabled
            }
        }
    }

    Button {
        id: toggle
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checkable: true
        text: checked ? "" : ""
        font: Theme.defaultFont
        padding: 0
        horizontalPadding: Theme.sectionHorizontalPadding / 2
        implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
        implicitHeight: contentItem.implicitHeight
        Accessible.name: checked ? "Hide system resources" : "Show system resources"

        background: Rectangle {
            radius: height / 2
            color: toggle.down ? Theme.pressedColor : toggle.hovered ? Theme.hoverColor : "transparent"
            border.width: toggle.visualFocus ? 1 : 0
            border.color: Theme.textColor
        }

        contentItem: Text {
            text: toggle.text
            font: toggle.font
            color: toggle.down ? Theme.selectedTextColor : Theme.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
