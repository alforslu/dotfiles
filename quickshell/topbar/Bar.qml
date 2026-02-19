// Bar.qml
import Quickshell
import QtQuick

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            // The screen from the screens list will be injected here
            required property var modelData
            screen: modelData
            // And used here ^

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30

            ClockWidget {
                anchors.centerIn: parent
            }
        }
    }
}
