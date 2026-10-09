import QtQuick
import Quickshell
import "Status"
import ".."

Rectangle {
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

        Volume {
            anchors.verticalCenter: parent.verticalCenter
        }

        Weather {
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
