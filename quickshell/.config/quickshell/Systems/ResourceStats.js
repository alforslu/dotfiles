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
