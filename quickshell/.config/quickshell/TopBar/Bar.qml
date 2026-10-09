// Bar.qml
import Quickshell
import ".."

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

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
                anchors.centerIn: parent
            }
            //
            // SystemStatus {
            //     anchors.right: parent.right
            //     anchors.rightMargin: 12
            //     anchors.verticalCenter: parent.verticalCenter
            // }

            SystemTime {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
            }


        }
    }
}
