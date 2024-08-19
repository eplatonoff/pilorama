import QtQuick 2.0
import Qt5Compat.GraphicalEffects

Item {
    id: element

    width: 50
    height: 50

    Image {
        fillMode: Image.PreserveAspectFit

        sourceSize.width: 24
        sourceSize.height: 24

        source: soundOn ? iconSound : iconNoSound

        property bool soundOn: !notifications.soundMuted

        property string iconSound: "qrc:/assets/img/sound.svg"
        property string iconNoSound: "qrc:/assets/img/nosound.svg"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        anchors.left: parent.left
        anchors.leftMargin: 3


        ColorOverlay{
            anchors.fill: parent
            source: parent
            color: colors.getColor("light")
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
