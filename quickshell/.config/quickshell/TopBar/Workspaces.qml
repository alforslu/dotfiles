import QtQuick
import QtQuick.Controls.Basic
import Quickshell.Hyprland
import ".."

Rectangle {
    color: Theme.backgroundColor

    implicitWidth: workspaceRow.implicitWidth + Theme.sectionHorizontalPadding * 2
    implicitHeight: workspaceRow.implicitHeight + Theme.sectionVerticalPadding * 2
    radius: Theme.defaultRadius

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: Theme.itemSpacing

        Repeater {
            model: Hyprland.workspaces

            delegate: Button {
                id: workspaceButton
                required property HyprlandWorkspace modelData

                text: modelData.name
                font: Theme.workspaceFont
                highlighted: modelData.focused
                onClicked: modelData.activate()

                implicitWidth: Math.max(36, contentItem.implicitWidth + leftPadding + rightPadding)
                implicitHeight: Theme.defaultBackgroundHeight
                padding: 4
                topInset: 2
                bottomInset: 2

                background: Rectangle {
                    radius: height / 2
                    color: workspaceButton.down ? Theme.pressedColor
                         : workspaceButton.highlighted ? Theme.selectedColor
                         : workspaceButton.hovered ? Theme.hoverColor
                         : Theme.backgroundColor

                    border.width: workspaceButton.visualFocus ? 1 : 0
                    border.color: Theme.textColor
                }

                contentItem: Text {
                    text: workspaceButton.text
                    font: workspaceButton.font

                    color: workspaceButton.highlighted || workspaceButton.down
                         ? Theme.selectedTextColor : Theme.textColor

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
