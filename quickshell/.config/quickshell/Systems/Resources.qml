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
    property var network: null
    property var lanInterfaces: []
    readonly property var lan: lanInterfaces.find(entry => entry.interfaceName === network?.interfaceName)
        ?? lanInterfaces[0] ?? null
    property var previousNetwork: null
    property var pendingRoute: null
    property bool networkPolling: false
    property bool probingIpv6: false

    function pollNetwork() {
        if (networkPolling || networkRoute.running)
            return;
        networkPolling = true;
        probingIpv6 = false;
        networkTimeout.restart();
        networkRoute.running = true;
    }

    function networkUnavailable() {
        network = null;
        previousNetwork = null;
        pendingRoute = null;
        networkPolling = false;
        networkTimeout.stop();
    }

    function pollLan() {
        if (lanTimeout.running || lanProcess.running)
            return;
        lanTimeout.restart();
        lanProcess.running = true;
    }

    Component.onCompleted: {
        pollNetwork();
        pollLan();
    }

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
        id: lanProcess
        command: ["ip", "-j", "-d", "-4", "address", "show", "up"]
        stdout: StdioCollector { id: lanOutput }
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            if (!lanTimeout.running)
                return;
            try {
                root.lanInterfaces = exitCode === 0 && exitStatus === 0
                    ? Stats.lanAddresses(lanOutput.text) : [];
            } catch (error) {
                root.lanInterfaces = [];
            }
            lanTimeout.stop();
        }
    }

    Timer {
        id: lanTimeout
        interval: 5000
        onTriggered: {
            root.lanInterfaces = [];
            lanProcess.running = false;
        }
    }

    Process {
        id: networkRoute
        command: ["ip", "-j", root.probingIpv6 ? "-6" : "-4", "route", "get",
            root.probingIpv6 ? "2606:4700:4700::1111" : "1.1.1.1"]
        stdout: StdioCollector { id: routeOutput }
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            if (!root.networkPolling)
                return;
            let route = null;
            if (exitCode === 0 && exitStatus === 0) {
                try {
                    route = Stats.networkRoute(routeOutput.text);
                } catch (error) {
                    route = null;
                }
            }
            if (route) {
                root.pendingRoute = route;
                networkFile.reload();
                // Start the deferred read only after selecting an interface.
                networkFile.text();
            } else if (!root.probingIpv6) {
                root.probingIpv6 = true;
                Qt.callLater(() => {
                    if (root.networkPolling)
                        networkRoute.running = true;
                });
            } else {
                root.networkUnavailable();
            }
        }
    }

    FileView {
        id: networkFile
        path: "/proc/net/dev"
        preload: false
        onLoaded: {
            if (!root.networkPolling)
                return;
            const sample = Stats.networkSnapshot(text(), root.pendingRoute, Date.now());
            if (!sample) {
                root.networkUnavailable();
                return;
            }
            root.network = Stats.networkUsage(sample, root.previousNetwork);
            root.previousNetwork = sample;
            root.networkPolling = false;
            networkTimeout.stop();
        }
        onLoadFailed: root.networkUnavailable()
    }

    Timer {
        id: networkTimeout
        interval: 5000
        onTriggered: {
            root.networkUnavailable();
            networkRoute.running = false;
        }
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
            root.pollNetwork();
            root.pollLan();
            cpuFile.reload();
            topologyFile.reload();
            memoryFile.reload();
            if (!temperatureProcess.running)
                temperatureProcess.running = true;
        }
    }
}
