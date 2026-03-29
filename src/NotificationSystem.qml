import QtQuick
import QtMultimedia

QtObject {
    id: notifications

    property var settings
    property var soundSettings
    property var trayRef
    property var masterModelRef
    property var timerRef
    property var queueRef
    property var clockRef
    property var macOSControllerRef
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
        onStatusChanged: {
            const status = notifications.soundNotification.status
            var currentSource = Qt.resolvedUrl(String(source));
            var defaultSource = Qt.resolvedUrl(String(notifications.soundSettings.defaultSound));
            if (status === SoundEffect.Error && currentSource !== defaultSource) {
                console.warn("SoundEffect: unsupported audio format:", source, "- will use fallback", notifications.soundSettings.defaultSound);
                notifications.currentSoundSource = notifications.soundSettings.defaultSound;
            } else if (status === SoundEffect.Ready && notifications.pendingPlay) {
                notifications.pendingPlay = false;
                notifications.soundNotification.play();
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
        trayRef.send(name)
    }

    function sendFromItem(item) {
        sendWithSound(masterModelRef.get(item.id).name)
        if (settings.showOnSegmentStart)
            trayRef.popUp()
    }

    function clearScheduled() {
        if (Qt.platform.os === "osx")
            macOSControllerRef.clearScheduledNotifications()
    }

    function scheduleNextSegment() {
        if (Qt.platform.os !== "osx")
            return

        clearScheduled()

        if (!timerRef.running)
            return

        const first = queueRef.first()
        if (!first) {
            const remainingSecs = Math.max(0, timerRef.remainingTime)
            if (remainingSecs <= 0)
                return
            macOSControllerRef.scheduleNotification(
                        "Time ran out",
                        "Duration: " + timerRef.durationBound / 60 + " min",
                        trayRef.notificationIconURL(), remainingSecs)
            return
        }

        const secs = Math.max(0, first.duration)
        if (secs <= 0)
            return
        const endTime = clockRef.getTimeAfter(secs).clock
        const message = "Duration: " + masterModelRef.get(first.id).duration / 60 +
                " min.  Ends at " + endTime
        macOSControllerRef.scheduleNotification(first.name + " started",
                                                message,
                                                trayRef.notificationIconURL(), secs)
    }
}
