import QtQuick

import "../../../Components"

Rectangle {
    id: rectangle

    anchors.top: parent.top
    anchors.right: parent.right
    anchors.left: parent.left
    height: 28

    color: "transparent"

    FaIcon {
        id: soundButton

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        glyph: notifications.soundMuted ? "\uf1f6" : "\uf0f3"

        onReleased: {
            notifications.toggleSoundNotifications();
        }
    }

    Image {
        id: logo

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        source: "qrc:/assets/img/white-logo.svg"
    }

    FaIcon {
        id: preferencesButton

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        glyph: "\uf0c9"

        onReleased: {
            stack.push(preferences);
        }
    }

}
