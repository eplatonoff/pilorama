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

            anchors.top: parent.top
            anchors.left: parent.left

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

            radius: 5000
            color: '#FF00FF'

            anchors.top: parent.top
            width: parent.width
            height: parent.width
        }

        Sequence {
            id: sequence

            anchors.top: clockFace.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }
}
