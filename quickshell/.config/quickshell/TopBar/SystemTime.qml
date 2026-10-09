import QtQuick
import ".."
import "../Systems"

Rectangle {
    color: Theme.backgroundColor
    radius: Theme.defaultRadius

    implicitWidth: label.implicitWidth
                   + Theme.sectionHorizontalPadding * 2
    implicitHeight: label.implicitHeight
                    + Theme.sectionVerticalPadding * 2

    Text {
        id: label
        anchors.centerIn: parent

        text: Time.time
        font: Theme.defaultFont
        color: Theme.textColor
    }
}
