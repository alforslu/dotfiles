import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "Status"
import ".."

Rectangle {
    id: root
    property real maximumWidth: Infinity

    color: Theme.backgroundColor
    radius: Theme.defaultRadius

    implicitWidth: statusRow.implicitWidth
                   + Theme.sectionHorizontalPadding * 2
    implicitHeight: statusRow.implicitHeight
                    + Theme.sectionVerticalPadding * 2

    Row {
        id: statusRow
        anchors.centerIn: parent
        spacing: Theme.itemSpacing

        Resources {
            maximumWidth: root.maximumWidth - volume.implicitWidth - weather.implicitWidth
                - (battery.visible ? battery.implicitWidth + statusRow.spacing : 0)
                - Theme.sectionHorizontalPadding * 2 - statusRow.spacing * 2
            anchors.verticalCenter: parent.verticalCenter
        }

        Loader {
            id: battery
            anchors.verticalCenter: parent.verticalCenter
            active: UPower.displayDevice.ready && UPower.displayDevice.isPresent
                && UPower.displayDevice.isLaptopBattery
            visible: active
            sourceComponent: Battery {}
        }

        Volume {
            id: volume
            anchors.verticalCenter: parent.verticalCenter
        }

        Weather {
            id: weather
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
