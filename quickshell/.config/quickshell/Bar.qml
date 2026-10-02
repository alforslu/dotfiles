// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root
    property string time

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30

            ClockWidget {
                anchors.centerIn: parent
                time: root.time
            }
        }
    }

    Process {
        id: dateProc
        command: ["date"]
        running: true

        // Process the stdout stream using a StdioCollector
        // Used to retrieve the text the process sends to stdout
        stdout: StdioCollector {
            onStreamFinished: root.time = this.text
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
