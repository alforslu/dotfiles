import QtQuick
import Quickshell
import "../.."

Rectangle {
    id: root

    required property string text
    required property string tooltip
    property real horizontalPadding: Theme.sectionHorizontalPadding / 2
    property bool tooltipsEnabled: true
    signal focusEntered()

    color: hover.hovered || activeFocus ? Theme.hoverColor : "transparent"
    radius: height / 2
    implicitWidth: label.implicitWidth + horizontalPadding * 2
    implicitHeight: Math.ceil(fontMetrics.height)
    activeFocusOnTab: enabled
    Accessible.role: Accessible.StaticText
    Accessible.name: text
    Accessible.description: tooltip
    onActiveFocusChanged: {
        if (activeFocus)
            focusEntered();
    }

    // Fallback glyphs must not change the row height or text baseline.
    FontMetrics {
        id: fontMetrics
        font: Theme.defaultFont
    }

    Text {
        id: label
        anchors.horizontalCenter: parent.horizontalCenter
        y: fontMetrics.ascent - baselineOffset
        text: root.text
        font: Theme.defaultFont
        color: Theme.textColor
    }

    HoverHandler { id: hover }

    PopupWindow {
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        visible: root.visible && root.tooltipsEnabled && (hover.hovered || root.activeFocus)
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
                text: root.tooltip
                textFormat: Text.PlainText
                font: Theme.defaultFont
                color: Theme.textColor
            }
        }
    }
}
