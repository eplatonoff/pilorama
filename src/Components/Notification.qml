import QtQuick
import QtMultimedia

QtObject {
    id: notifications

    property SoundEffect sound: SoundEffect {
        id: soundNotification

        muted: !appSettings.audioNotificationsEnabled
        source: "qrc:assets/sound/drum_roll.wav"
    }

    function send(name) {
    // if (appSettings.audioNotificationsEnabled) {
    //     soundNotification.play();
    // }
    // tray.notify(name)
    }
    function sendFromItem(item) {
    //     send(masterModel.get(item.id).name)
    }
}
