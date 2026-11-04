pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "ResourceStats.js" as Stats

Singleton {
    id: root

    property var previousCpu: ({})
    property var cpu: []
    property var memory: null
    property var topology: ({})
    property string temperatureText: ""

    readonly property var temperatures: {
        try {
            return Stats.cpuTemperatures(temperatureText, topology);
        } catch (error) {
            return null;
        }
    }

    readonly property var cpuPercent: cpu.find(sample => sample.name === "cpu")?.percent ?? null
    readonly property var cores: cpu.filter(sample => sample.name !== "cpu")

    FileView {
        id: cpuFile
        path: "/proc/stat"
        onLoaded: {
            const current = Stats.cpuSnapshot(text());
            root.cpu = Stats.cpuUsage(current, root.previousCpu);
            root.previousCpu = current;
        }
        onLoadFailed: {
            root.cpu = [];
            root.previousCpu = ({});
        }
    }

    FileView {
        id: topologyFile
        path: "/proc/cpuinfo"
        onLoaded: root.topology = Stats.cpuTopology(text())
        onLoadFailed: root.topology = ({})
    }

    FileView {
        id: memoryFile
        path: "/proc/meminfo"
        onLoaded: root.memory = Stats.memoryUsage(text())
        onLoadFailed: root.memory = null
    }

    Process {
        id: temperatureProcess
        running: true
        command: ["sensors", "-j"]
        stdout: StdioCollector {
            id: temperatureOutput
            onStreamFinished: root.temperatureText = text
        }
        // Other devices may report errors while CPU sensors still return valid data.
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            if (exitStatus !== 0 || (exitCode !== 0 && !temperatureOutput.text.trim()))
                root.temperatureText = "";
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuFile.reload();
            topologyFile.reload();
            memoryFile.reload();
            if (!temperatureProcess.running)
                temperatureProcess.running = true;
        }
    }
}
