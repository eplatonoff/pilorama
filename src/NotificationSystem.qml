import QtQuick
import QtMultimedia

QtObject {
    id: notifications

    property var settings
    readonly property bool soundMuted: settings ? settings.soundMuted : false

    // Default and effective sound paths
    property url effectiveSoundPath: soundSettings.effectiveSoundPath
    property url currentSoundSource: effectiveSoundPath
    property bool pendingPlay: false

    onEffectiveSoundPathChanged: {
        currentSoundSource = effectiveSoundPath;
    }

    // QtObject has no default property; SoundEffect must be declared as a property.
    property SoundEffect soundNotification: SoundEffect {
        muted: notifications.soundMuted
        // Let Qt choose the default audio device to avoid null connections
        source: notifications.currentSoundSource
        onStatusChanged: function(status) {
            var currentSource = Qt.resolvedUrl(String(source));
            var defaultSource = Qt.resolvedUrl(String(soundSettings.defaultSound));
            if (status === SoundEffect.Error && currentSource !== defaultSource) {
                console.warn("SoundEffect: unsupported audio format:", source, "- will use fallback", soundSettings.defaultSound);
                notifications.currentSoundSource = soundSettings.defaultSound;
            } else if (status === SoundEffect.Ready && notifications.pendingPlay) {
                notifications.pendingPlay = false;
                soundNotification.play();
            }
        }
    }

    onSoundMutedChanged: {
        if (soundMuted)
            stopSound();
    }

    function toggleSoundNotifications() {
        if (settings) {
            settings.soundMuted = !settings.soundMuted;
        }
    }

    function stopSound() {
        pendingPlay = false;
        soundNotification.stop();
    }

    function playNotificationSound() {
        pendingPlay = true;
        if (soundNotification.status === SoundEffect.Ready) {
            pendingPlay = false;
            soundNotification.play();
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
