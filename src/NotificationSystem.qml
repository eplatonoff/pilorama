import QtQuick
import QtMultimedia

import "utils/sound.mjs" as SoundUtils

QtObject {
    id: notifications

    property bool soundMuted: false

    // Default and effective sound paths
    property url effectiveSoundPath: SoundUtils.isWav(appSettings.soundPath) ? appSettings.soundPath : appSettings.defaultSound

    // QtObject has no default property; SoundEffect must be declared as a property.
    property SoundEffect soundNotification: SoundEffect {
        muted: notifications.soundMuted
        // Let Qt choose the default audio device to avoid null connections
        source: notifications.effectiveSoundPath
        onStatusChanged: {
            if (status === SoundEffect.Error && source !== appSettings.defaultSound) {
                console.warn("SoundEffect: unsupported audio format:", source, "- will use fallback", appSettings.defaultSound);
            }
        }
    }

    property SoundEffect fallbackSound: SoundEffect {
        muted: soundNotification.muted
        source: appSettings.defaultSound
    }

    onSoundMutedChanged: {
        if (soundMuted)
            stopSound();
    }

    function toggleSoundNotifications() {
        soundMuted = !soundMuted;
    }

    function stopSound() {
        soundNotification.stop();
        fallbackSound.stop();
    }

    function playNotificationSound() {
        if (soundNotification.status === SoundEffect.Ready) {
            soundNotification.play();
        } else {
            // Fallback quickly if current source is not ready/unsupported
            fallbackSound.play();
        }
    }

    function sendWithSound(name) {
        playNotificationSound();
        tray.send(name)
    }

    function sendFromItem(item) {
        sendWithSound(masterModel.get(item.id).name)
        if (appSettings.showOnSegmentStart)
            tray.popUp()
    }
}
