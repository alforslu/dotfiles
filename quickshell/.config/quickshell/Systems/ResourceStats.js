.pragma library

function cpuSnapshot(text) {
    const snapshot = {};
    for (const line of text.trim().split("\n")) {
        const fields = line.trim().split(/\s+/);
        if (!/^cpu\d*$/.test(fields[0]))
            continue;
        // Guest time is already included in user/nice; only sum the first eight counters.
        const counters = fields.slice(1, 9).map(Number);
        if (counters.length < 4 || counters.some(value => !Number.isFinite(value) || value < 0))
            continue;
        snapshot[fields[0]] = {
            total: counters.reduce((sum, value) => sum + value, 0),
            idle: counters[3] + (counters[4] || 0)
        };
    }
    return snapshot;
}

function cpuUsage(current, previous) {
    return Object.keys(current).map(name => {
        const sample = current[name];
        const old = previous[name];
        const elapsed = old ? sample.total - old.total : 0;
        const idle = old ? sample.idle - old.idle : 0;
        const percent = elapsed > 0 && idle >= 0
            ? Math.max(0, Math.min(100, 100 * (elapsed - idle) / elapsed)) : null;
        return { name: name, percent: percent };
    });
}

function memoryUsage(text) {
    const total = text.match(/^MemTotal:\s+(\d+)\s+kB$/m);
    const available = text.match(/^MemAvailable:\s+(\d+)\s+kB$/m);
    if (!total || !available || Number(total[1]) <= 0 || Number(available[1]) > Number(total[1]))
        return null;
    const totalBytes = Number(total[1]) * 1024;
    const usedBytes = totalBytes - Number(available[1]) * 1024;
    return { used: usedBytes / (1024 ** 3), total: totalBytes / (1024 ** 3), percent: usedBytes / totalBytes * 100 };
}

function cpuTopology(text) {
    const topology = {};
    for (const block of text.trim().split(/\n\s*\n/)) {
        const processor = block.match(/^processor\s*:\s*(\d+)\s*$/m);
        const packageId = block.match(/^physical id\s*:\s*(\d+)\s*$/m);
        const coreId = block.match(/^core id\s*:\s*(\d+)\s*$/m);
        if (!processor || !packageId || !coreId)
            continue;
        const key = Number(packageId[1]) + ":" + Number(coreId[1]);
        if (!topology[key])
            topology[key] = [];
        topology[key].push(Number(processor[1]));
    }
    for (const key of Object.keys(topology))
        topology[key].sort((a, b) => a - b);
    return topology;
}

function cpuTemperatures(text, topology = {}) {
    const sensors = JSON.parse(text);
    if (!sensors || typeof sensors !== "object" || Array.isArray(sensors))
        return null;
    const chips = Object.keys(sensors).filter(name => /^(coretemp|k10temp|zenpower)-/.test(name));
    const readings = [];
    const packages = [];
    for (const chip of chips) {
        const features = sensors[chip];
        if (!features || typeof features !== "object")
            continue;
        const packageLabel = Object.keys(features).find(label => /^Package id \d+$/.test(label));
        const packageId = packageLabel ? Number(packageLabel.match(/\d+$/)[0]) : null;
        for (const label of Object.keys(features)) {
            const feature = features[label];
            if (!feature || typeof feature !== "object")
                continue;
            for (const key of Object.keys(feature)) {
                const value = feature[key];
                if (!/^temp\d+_input$/.test(key) || typeof value !== "number"
                    || !Number.isFinite(value) || value <= -273.15 || value > 200)
                    continue;
                const core = label.match(/^Core (\d+)$/);
                const processors = core && packageId !== null ? topology[packageId + ":" + Number(core[1])] : null;
                const name = processors?.length ? processors.map(id => "CPU" + id).join(" / ")
                    : label.replace(/^Package id \d+$/, "Package");
                readings.push({ name: chips.length > 1 ? chip + ": " + name : name, value: value });
                if (/^(Package id|Tdie)/.test(label) || (label === "Tctl" && !features.Tdie))
                    packages.push(value);
            }
        }
    }
    if (!readings.length)
        return null;
    return {
        temperature: Math.max(...(packages.length ? packages : readings.map(reading => reading.value))),
        readings: readings
    };
}

function networkRoute(text) {
    const routes = JSON.parse(text);
    if (!Array.isArray(routes))
        return null;
    const route = routes.find(route => route && typeof route.dev === "string"
        && route.dev && route.dev !== "lo" && typeof (route.prefsrc || route.src) === "string"
        && (route.prefsrc || route.src).trim());
    return route ? { interfaceName: route.dev, address: route.prefsrc || route.src } : null;
}

function networkSnapshot(text, route, timestamp) {
    if (!route || !Number.isFinite(timestamp))
        return null;
    for (const line of text.split("\n")) {
        const separator = line.indexOf(":");
        if (separator < 0 || line.slice(0, separator).trim() !== route.interfaceName)
            continue;
        const fields = line.slice(separator + 1).trim().split(/\s+/);
        if (fields.length < 16 || !/^\d+$/.test(fields[0]) || !/^\d+$/.test(fields[8]))
            return null;
        const received = Number(fields[0]);
        const sent = Number(fields[8]);
        if (!Number.isFinite(received) || !Number.isFinite(sent))
            return null;
        return { interfaceName: route.interfaceName, address: route.address,
            received: received, sent: sent, timestamp: timestamp };
    }
    return null;
}

function networkUsage(current, previous) {
    if (!current)
        return null;
    const seconds = previous ? (current.timestamp - previous.timestamp) / 1000 : 0;
    const continuous = previous && current.interfaceName === previous.interfaceName
        && seconds > 0 && current.received >= previous.received && current.sent >= previous.sent;
    return { interfaceName: current.interfaceName, address: current.address,
        received: current.received, sent: current.sent,
        seconds: continuous ? seconds : null,
        download: continuous ? (current.received - previous.received) / seconds : null,
        upload: continuous ? (current.sent - previous.sent) / seconds : null };
}

function formatBytes(bytes, precision = 1) {
    if (typeof bytes !== "number" || !Number.isFinite(bytes) || bytes < 0)
        return "N/A";
    const units = ["B", "KiB", "MiB", "GiB"];
    let unit = 0;
    while (bytes >= 1024 && unit < units.length - 1) {
        bytes /= 1024;
        unit++;
    }
    return bytes.toFixed(unit === 0 ? 0 : precision) + " " + units[unit];
}

function networkTooltip(network) {
    if (!network)
        return "Network unavailable";
    const rates = network.download === null ? "\nCollecting a second sample…"
        : "\nDownload: " + formatBytes(network.download, 3) + "/s"
            + "\nUpload: " + formatBytes(network.upload, 3) + "/s";
    return "Interface: " + network.interfaceName + rates
        + "\nReceived: " + formatBytes(network.received, 3)
        + "\nSent: " + formatBytes(network.sent, 3);
}

function lanAddresses(text) {
    const interfaces = JSON.parse(text);
    if (!Array.isArray(interfaces))
        return [];
    const addresses = [];
    const virtualAddresses = [];
    for (const device of interfaces) {
        const kind = device?.linkinfo?.info_kind;
        if (!device || typeof device.ifname !== "string" || device.link_type !== "ether"
            || !Array.isArray(device.flags) || !device.flags.includes("UP")
            || device.operstate === "DOWN" || !Array.isArray(device.addr_info)
            || (kind && !["vlan", "bridge", "bond", "team", "macvlan", "ipvlan"].includes(kind)))
            continue;
        if (["bridge", "bond", "team"].includes(kind) && !interfaces.some(member =>
                member?.master === device.ifname && member.link_type === "ether" && !member.linkinfo?.info_kind))
            continue;
        for (const address of device.addr_info) {
            if (address?.family === "inet" && address.scope === "global"
                && typeof address.local === "string" && address.local && !address.tentative)
                (kind ? virtualAddresses : addresses).push({ interfaceName: device.ifname, address: address.local });
        }
    }
    return addresses.concat(virtualAddresses);
}
