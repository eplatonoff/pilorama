import QtQuick

import "../utils/sound.mjs" as SoundUtils

QtObject {
    id: root

    property var settings
    property url defaultSound: ""
    property url soundPath: defaultSound

    readonly property url effectiveSoundPath: SoundUtils.isWav(soundPath) ? soundPath : defaultSound
    readonly property string displayName: SoundUtils.soundFileName(soundPath)
    readonly property string displayPath: SoundUtils.clampedSoundPath(soundPath)

    function restoreDefault() {
        soundPath = defaultSound;
    }

    function applySelectedFile(fileUrl) {
        if (!fileUrl) {
            return;
        }
        soundPath = fileUrl;
    }

    function isWav(path) {
        return SoundUtils.isWav(path);
    }

    onSettingsChanged: {
        if (settings && settings.soundPath !== soundPath) {
            soundPath = settings.soundPath;
        } else if (!settings) {
            soundPath = defaultSound;
        }
    }

    onSoundPathChanged: {
        if (settings && settings.soundPath !== soundPath) {
            settings.soundPath = soundPath;
        }
    }

    property Connections settingsConnections: Connections {
        target: settings

        function onSoundPathChanged() {
            if (root.soundPath !== settings.soundPath) {
                root.soundPath = settings.soundPath;
            }
        }
    }
}
