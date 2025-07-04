import QtQuick
import QtMultimedia


QtObject {
    id: notifications

    property bool soundMuted: false

    property MediaDevices mediaDevices: MediaDevices {
        id: mediaDevices
    }

    property SoundEffect sound: SoundEffect {
        id: soundNotification
        muted: notifications.soundMuted
        audioDevice: mediaDevices.defaultAudioOutput
        source: "qrc:assets/sound/drum_roll.wav"
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
    }

    function sendWithSound(name) {
        soundNotification.play();
        tray.send(name)
    }

    function sendFromItem(item) {
        sendWithSound(masterModel.get(item.id).name)
        if (appSettings.showOnSegmentStart)
            tray.popUp()
    }

    function clearScheduled() {
        if (Qt.platform.os === "osx")
            MacOSController.clearScheduledNotifications()
    }

    function scheduleNextSegment() {
        if (Qt.platform.os !== "osx")
            return

        clearScheduled()

        if (!globalTimer.running)
            return

        const first = pomodoroQueue.first()
        if (!first) {
            MacOSController.scheduleNotification(
                        "Time ran out",
                        "Duration: " + globalTimer.durationBound / 60 + " min",
                        tray.notificationIconURL(), 0)
            return
        }

        const secs = first.duration
        const endTime = clock.getTimeAfter(secs).clock
        const message = "Duration: " + masterModel.get(first.id).duration / 60 +
                " min.  Ends at " + endTime
        MacOSController.scheduleNotification(first.name + " started",
                                             message,
                                             tray.notificationIconURL(), secs)
    }
}
