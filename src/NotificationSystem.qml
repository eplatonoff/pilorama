import QtQuick 2.0
import QtMultimedia 5.13


QtObject {
    id: notifications

    property bool soundMuted: false

    property SoundEffect sound: SoundEffect {
        id: soundNotification
        muted: notifications.soundMuted
        source: "../assets/sound/drum_roll.wav"
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
//        send(name);
        tray.send(name)
    }

    function sendFromItem(item) {
//        sendWithSound(NotificationSystem.POMODORO)
        sendWithSound(masterModel.get(item.id).name)
    }
}
