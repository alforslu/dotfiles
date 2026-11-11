import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../.."

Button {
    id: batteryButton

    property var battery: UPower.displayDevice
    property int profile: PowerProfiles.profile
    readonly property int percent: Math.round(battery.percentage * 100)
    readonly property bool charging: battery.state === UPowerDeviceState.Charging
    readonly property string profileLabel: {
        switch (profile) {
        case PowerProfile.Performance: return "P";
        case PowerProfile.PowerSaver: return "PS";
        case PowerProfile.Balanced: return "B";
        default: return "?";
        }
    }
    readonly property string batteryIcon: charging ? ""
        : ["", "", "", "", ""][Math.max(0, Math.min(4, Math.floor(percent / 20)))]
    readonly property string tooltip: {
        if (battery.state === UPowerDeviceState.FullyCharged)
            return "Fully charged";
        if (charging)
            return battery.timeToFull > 0
                ? "Charging · " + formatDuration(battery.timeToFull) + " until full"
                : "Charging · Estimate unavailable";
        if (battery.state === UPowerDeviceState.PendingCharge)
            return "Plugged in · Not charging";
        if (battery.state === UPowerDeviceState.Discharging)
            return battery.timeToEmpty > 0
                ? formatDuration(battery.timeToEmpty) + " remaining"
                : "Battery life estimate unavailable";
        return UPowerDeviceState.toString(battery.state);
    }

    function formatDuration(seconds) {
        const minutes = Math.max(1, Math.ceil(seconds / 60));
        return Math.floor(minutes / 60) + "h " + minutes % 60 + "m";
    }

    visible: battery.ready && battery.isPresent && battery.isLaptopBattery
    text: batteryIcon + " " + percent + "% (" + profileLabel + ")"
    font: Theme.defaultFont
    hoverEnabled: true
    padding: 0
    horizontalPadding: Theme.sectionHorizontalPadding / 2
    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight
    Accessible.name: "Battery " + percent + " percent. Power profile: " + PowerProfile.toString(profile)
    Accessible.description: tooltip + ". Select a power profile"
    onClicked: {
        if (!profileMenu.running)
            profileMenu.running = true;
    }

    Process {
        id: profileMenu
        command: ["bash", Quickshell.shellPath("scripts/power-profile.sh")]
        stderr: StdioCollector { id: menuError }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0)
                console.warn("Power profile selector failed:", menuError.text.trim());
        }
    }

    background: Rectangle {
        radius: height / 2
        color: batteryButton.down ? Theme.pressedColor : batteryButton.hovered ? Theme.hoverColor : "transparent"
        border.width: batteryButton.visualFocus ? 1 : 0
        border.color: Theme.textColor
    }

    contentItem: Text {
        text: batteryButton.text
        font: batteryButton.font
        color: batteryButton.down ? Theme.selectedTextColor : Theme.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    PopupWindow {
        anchor.item: batteryButton
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        visible: batteryButton.visible && !profileMenu.running
            && (batteryButton.hovered || batteryButton.visualFocus)
        color: "transparent"
        implicitWidth: tooltipLabel.implicitWidth + Theme.sectionHorizontalPadding * 2
        implicitHeight: tooltipLabel.implicitHeight + Theme.tooltipPadding * 2

        Rectangle {
            anchors.fill: parent
            color: Theme.backgroundColor
            radius: Theme.defaultRadius
            border.width: 1
            border.color: Theme.hoverColor

            Text {
                id: tooltipLabel
                anchors.centerIn: parent
                text: batteryButton.tooltip
                textFormat: Text.PlainText
                font: Theme.defaultFont
                color: Theme.textColor
            }
        }
    }
}
