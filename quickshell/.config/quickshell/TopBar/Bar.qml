// Bar.qml
import Quickshell
import Quickshell.Hyprland
import QtQuick
import ".."

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData
            screen: modelData
            readonly property var mainWorkspace: Hyprland.workspaces.values.find(workspace => workspace.id === 1)
            readonly property bool isMainMonitor: mainWorkspace?.monitor?.name === modelData.name

            color: Qt.rgba(0.09, 0.09, 0.09, 0.7)

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Theme.barHeight

            // WindowInfo {
            //     anchors.left: parent.left
            //     anchors.leftMargin: 12
            //     anchors.verticalCenter: parent.verticalCenter
            // }
            //
            Workspaces {
                visible: bar.isMainMonitor
                anchors.centerIn: parent
            }
            //
            // SystemStatus {
            //     anchors.right: parent.right
            //     anchors.rightMargin: 12
            //     anchors.verticalCenter: parent.verticalCenter
            // }

            SystemTime {
                id: clock

                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                // Move to center when not on main monitor
                states: State {
                    when: !bar.isMainMonitor

                    AnchorChanges {
                        target: clock
                        anchors.right: undefined
                        anchors.horizontalCenter: clock.parent.horizontalCenter
                    }
                }
            }


        }
    }
}
