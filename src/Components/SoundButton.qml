import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: element

    width: 50
    height: 50

    Image {
        property bool soundOn: !notifications.soundMuted
        sourceSize.height: 23
        sourceSize.width: 23
        source: soundOn ? iconSound : iconNoSound
        antialiasing: true
        fillMode: Image.PreserveAspectFit

        property color color: colors.fakeLight

        property string iconSound: "../assets/img/sound.svg"
        property string iconNoSound: "../assets/img/nosound.svg"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0


        ColorOverlay{
            anchors.fill: parent
            source: parent
            color: appSettings.darkMode ? colors.fakeDark : colors.fakeLight
            antialiasing: true
        }
    }

    MouseArea {
        x: 13
        y: 13
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor

        onReleased: {
            notifications.toggleSoundNotifications();
        }
    }
}
