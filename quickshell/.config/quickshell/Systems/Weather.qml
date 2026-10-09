pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string location: Quickshell.env("WEATHER_LOCATION") || ""
    property string text: "..."
    property string tooltip: "Fetching weather..."

    function refresh() {
        if (!fetch.running) {
            fetch.running = true;
        }
    }

    Timer {
        interval: 5 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: fetch
        running: true
        command: ["curl", "--fail", "--silent", "--show-error", "--max-time", "15", "--retry", "10", "--retry-delay", "2", "--retry-all-errors", "https://wttr.in/" + encodeURIComponent(root.location) + "?format=j1"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const weather = JSON.parse(this.text).current_condition[0];
                    const description = weather.weatherDesc[0].value;

                    if (typeof weather.temp_C !== "string" || typeof description !== "string") {
                        throw new Error("Invalid weather response");
                    }
                    root.text = weather.temp_C + "°C";
                    root.tooltip = (root.location ? root.location + ": " : "") + description;
                } catch (error) {
                    root.text = "N/A";
                    root.tooltip = "Invalid weather response";
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0) {
                root.text = "N/A";
                root.tooltip = "Could not fetch weather";
            }
        }
    }

}
