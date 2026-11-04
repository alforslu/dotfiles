import QtQuick
import QtQuick.Controls.Basic
import "../.."
import "../../Systems" as Systems
import "../../Systems/ResourceStats.js" as Stats

Item {
    id: root

    property alias expanded: toggle.checked
    property real maximumWidth: Infinity

    implicitWidth: reveal.width + toggle.implicitWidth
    implicitHeight: toggle.implicitHeight
    Keys.onEscapePressed: expanded = false
    onExpandedChanged: {
        if (!expanded) {
            reveal.contentX = 0;
            toggle.forceActiveFocus(Qt.OtherFocusReason);
        }
    }

    Flickable {
        id: reveal
        property real progress: root.expanded ? 1 : 0

        anchors.right: toggle.left
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(metrics.implicitWidth, Math.max(0, root.maximumWidth - toggle.implicitWidth)) * progress
        height: metrics.implicitHeight
        contentWidth: metrics.implicitWidth
        contentHeight: metrics.implicitHeight
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        visible: width > 0
        enabled: root.expanded && !revealAnimation.running
        interactive: enabled && contentWidth > width

        function scrollTo(position) {
            contentX = Math.max(0, Math.min(position, Math.max(0, contentWidth - width)));
        }

        function ensureVisible(item) {
            if (item.x < contentX)
                scrollTo(item.x);
            else if (item.x + item.width > contentX + width)
                scrollTo(item.x + item.width - width);
        }

        function tooltipAllowed(item) {
            return enabled && item.x + item.width > contentX && item.x < contentX + width;
        }

        onWidthChanged: scrollTo(contentX)
        onContentWidthChanged: scrollTo(contentX)

        WheelHandler {
            target: null
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            enabled: reveal.interactive
            onWheel: event => {
                const pixels = event.pixelDelta.x || event.pixelDelta.y;
                const delta = pixels || (event.angleDelta.x || event.angleDelta.y) / 3;
                reveal.scrollTo(reveal.contentX - delta);
                event.accepted = true;
            }
        }

        Behavior on progress {
            NumberAnimation {
                id: revealAnimation
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Row {
            id: metrics
            spacing: Theme.itemSpacing

            ResourceMetric {
                readonly property var network: Systems.Resources.network
                text: !network ? "NET N/A" : network.download === null ? "NET Sampling…"
                    : "▾ " + Stats.formatBytes(network.download) + "/s ▴ " + Stats.formatBytes(network.upload) + "/s"
                tooltip: Stats.networkTooltip(network)
                tooltipsEnabled: reveal.tooltipAllowed(this)
                onFocusEntered: reveal.ensureVisible(this)
            }

            ResourceMetric {
                readonly property var lan: Systems.Resources.lan
                readonly property string address: lan?.address ?? ""
                text: !lan ? "IP N/A" : "IP " + (address.length > 24
                    ? address.slice(0, 12) + "…" + address.slice(-8) : address)
                tooltip: lan ? "LAN IPv4 addresses\n" + Systems.Resources.lanInterfaces.map(entry =>
                    entry.interfaceName + ": " + entry.address).join("\n") : "LAN IPv4 unavailable"
                tooltipsEnabled: reveal.tooltipAllowed(this)
                onFocusEntered: reveal.ensureVisible(this)
            }

            ResourceMetric {
                text: Systems.Resources.cpuPercent === null ? "CPU N/A"
                    : "CPU " + Math.round(Systems.Resources.cpuPercent) + "%"
                tooltip: "CPU usage (logical)\n" + (Systems.Resources.cores.length
                    ? Systems.Resources.cores.map(core => core.name.toUpperCase() + ": "
                        + (core.percent === null ? "Sampling…" : Math.round(core.percent) + "%")).join("\n")
                    : "Unavailable")
                tooltipsEnabled: reveal.tooltipAllowed(this)
                onFocusEntered: reveal.ensureVisible(this)
            }

            ResourceMetric {
                text: Systems.Resources.temperatures === null ? "Temp N/A"
                    : Math.round(Systems.Resources.temperatures.temperature) + "°C"
                tooltip: Systems.Resources.temperatures === null ? "CPU temperature sensors unavailable"
                    : Systems.Resources.temperatures.readings.map(reading =>
                        reading.name + ": " + reading.value.toFixed(1) + "°C").join("\n")
                tooltipsEnabled: reveal.tooltipAllowed(this)
                onFocusEntered: reveal.ensureVisible(this)
            }

            ResourceMetric {
                text: Systems.Resources.memory === null ? "RAM N/A"
                    : "RAM " + Systems.Resources.memory.used.toFixed(1) + " GiB · "
                        + Math.round(Systems.Resources.memory.percent) + "%"
                tooltip: Systems.Resources.memory === null ? "Memory information unavailable"
                    : "RAM: " + Systems.Resources.memory.used.toFixed(1) + " / "
                        + Systems.Resources.memory.total.toFixed(1) + " GiB\n"
                        + "Usage: " + Math.round(Systems.Resources.memory.percent) + "%"
                tooltipsEnabled: reveal.tooltipAllowed(this)
                onFocusEntered: reveal.ensureVisible(this)
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
