import QtQuick

import "Components"
import "../../Components"

Item {
    id: timerContainer

    Item {
        id: screen

        anchors.fill: parent
        anchors.margins: 16

        FaIcon {
            id: preferencesButton

            anchors.left: parent.left
            anchors.top: parent.top
            glyph: "\uf0c9"

            onReleased: {
                stack.push(preferences);
            }
        }
        TimerModel {
            id: timerModel

            data: data
            title: title
        }
        Rectangle {
            id: clockFace

            anchors.top: parent.top
            color: '#FF0000'
            height: parent.width
            radius: 5000
            width: parent.width
        }
        Sequence {
            id: sequence

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: clockFace.bottom
            anchors.topMargin: 16
        }
    }
}
