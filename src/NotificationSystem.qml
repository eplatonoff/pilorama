import QtQuick
import QtMultimedia


QtObject {
    id: notifications

    property bool soundMuted: false

    property SoundEffect sound: SoundEffect {
        id: soundNotification
        muted: notifications.soundMuted
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
    }
}
