import QtQuick 2.0
import QtMultimedia 5.13

import notifications 1.0


NotificationSystem {
    id: notifications

    property bool soundMuted: false

    property SoundEffect sound: SoundEffect {
        id: soundNotification
        muted: notifications.soundMuted
        source: "./sound/piano-low.wav"
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

    function sendWithSound(type) {
        soundNotification.play();
        send(type);
    }

    function sendFromItem(item) {
        switch (item.type) {
        case "pomodoro":
            sendWithSound(NotificationSystem.POMODORO); break;
        case "pause":
            sendWithSound(NotificationSystem.PAUSE); break;
        case "break":
            sendWithSound(NotificationSystem.BREAK); break;
        default:
            throw "unknown time segment type";
        }
    }
}
