import QtQuick
import QtQuick.Controls.Basic
import Quickshell.Hyprland
import ".."

Rectangle {
    id: root
    readonly property bool workspaceEntering: workspaceRow.children.some(item => item.entering === true)
    color: Theme.backgroundColor

    // Note -8 below, this is different from rest of UI.
    implicitWidth: workspaceRow.implicitWidth + Theme.sectionHorizontalPadding * 2 - 8
    implicitHeight: workspaceRow.implicitHeight + Theme.sectionVerticalPadding * 2
    radius: Theme.defaultRadius

    Behavior on implicitWidth {
        enabled: !root.workspaceEntering
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: workspaceRow
        anchors.left: parent.left
        anchors.leftMargin: Theme.sectionHorizontalPadding - 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.itemSpacing

        move: Transition {
            enabled: !root.workspaceEntering
            NumberAnimation {
                property: "x"
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            model: Hyprland.workspaces

            delegate: Button {
                id: workspaceButton
                required property HyprlandWorkspace modelData
                readonly property bool entering: entrance.running
                onWidthChanged: if (entering) workspaceRow.forceLayout()

                NumberAnimation on width {
                    id: entrance
                    from: 0
                    to: workspaceButton.implicitWidth
                    duration: 140
                    easing.type: Easing.OutCubic
                }

                text: modelData.name
                font: Theme.workspaceFont
                highlighted: modelData.focused
                onClicked: modelData.activate()

                implicitWidth: Math.max(36, contentItem.implicitWidth + leftPadding + rightPadding)
                implicitHeight: Theme.defaultBackgroundHeight
                padding: 4
                clip: true
                topInset: 2
                bottomInset: 2

                background: Rectangle {
                    radius: height / 2
                    color: workspaceButton.down ? Theme.pressedColor : workspaceButton.highlighted ? Theme.selectedColor : workspaceButton.hovered ? Theme.hoverColor : Theme.backgroundColor

                    border.width: workspaceButton.visualFocus ? 1 : 0
                    border.color: Theme.textColor
                }

                contentItem: Text {
                    text: workspaceButton.text
                    font: workspaceButton.font

                    color: workspaceButton.highlighted || workspaceButton.down ? Theme.selectedTextColor : Theme.textColor

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Tray {}

    }
}
