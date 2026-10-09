import QtQuick
import Quickshell
import "../.."
import "../../Systems" as Systems

Rectangle {
    id: weatherSection

    color: refreshTap.pressed ? Theme.pressedColor : hover.hovered ? Theme.hoverColor : "transparent"

    radius: height / 2
    implicitWidth: label.implicitWidth + Theme.sectionHorizontalPadding
    implicitHeight: label.implicitHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: Systems.Weather.text
        font: Theme.defaultFont
        color: Theme.textColor
    }

    HoverHandler {
        id: hover
    }

    TapHandler {
        id: refreshTap
        onTapped: Systems.Weather.refresh()
    }

    PopupWindow {
        anchor.item: weatherSection
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        visible: hover.hovered

        color: "transparent"
        implicitWidth: tooltipLabel.implicitWidth + Theme.sectionHorizontalPadding * 2
        implicitHeight: tooltipLabel.implicitHeight + Theme.sectionVerticalPadding * 2 + Theme.tooltipPadding

        Rectangle {
            anchors.fill: parent
            color: Theme.backgroundColor
            radius: Theme.defaultRadius

            Text {
                id: tooltipLabel
                anchors.centerIn: parent
                text: Systems.Weather.tooltip
                textFormat: Text.PlainText
                font: Theme.defaultFont
                color: Theme.textColor
            }
        }
    }
}
