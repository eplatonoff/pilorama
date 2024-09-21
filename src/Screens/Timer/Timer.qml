import QtQuick

import "Components"
import "../../Components"

Item {
    id: screen

    Item {
        id: content

        anchors.fill: parent
        anchors.margins: 16


        Header {
            id: header
        }

        FaIcon {
            id: soundButton

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            glyph: appSettings.audioNotificationsEnabled ? "\uf0f3" : "\uf1f6"

            onReleased: {
                appSettings.audioNotificationsEnabled = !appSettings.audioNotificationsEnabled;
            }
        }

    }
}
