function normalizePath(path) {
    return path ? String(path) : "";
}

export function isWav(path) {
    const text = normalizePath(path);
    return text !== "" && text.toLowerCase().endsWith(".wav");
}

export function soundFileName(path, placeholder = "—") {
    const text = normalizePath(Qt.resolvedUrl(String(path)));
    if (text === "") {
        return placeholder;
    }
    const lastSlash = text.lastIndexOf("/");
    return lastSlash >= 0 ? text.slice(lastSlash + 1) : text;
}

export function clampedSoundPath(path, maxLength = 500) {
    const text = normalizePath(Qt.resolvedUrl(String(path)));
    if (text === "") {
        return "";
    }
    if (text.length <= maxLength) {
        return text;
    }
    const head = Math.floor(maxLength / 2);
    const tail = maxLength - head - 1;
    return text.slice(0, head) + "…" + text.slice(-tail);
}

export function directoryFromPath(path) {
    const text = normalizePath(Qt.resolvedUrl(String(path)));
    if (text === "") {
        return "";
    }
    const lastSlash = text.lastIndexOf("/");
    return lastSlash > 0 ? text.slice(0, lastSlash) : "";
}
