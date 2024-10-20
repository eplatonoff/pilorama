import QtQuick
import QtCore

import "Components"
import "Components/Timer"
import "../../Components"

Item {
    id: timerContainer

    function getBurnerModel() {
        return burnerModel;
    }
    function getCanvas() {
        return canvas;
    }
    function getMouseTrackerArea() {
        return mouseTrackerArea;
    }
    function getSequence() {
        return sequence;
    }
    function getTimerModel() {
        return timerModel;
    }

    Item {
        id: timerScreen

        anchors.fill: parent
        anchors.margins: 16

        TimerModel {
            id: timerModel

            data: data
            title: title
        }
        Settings {
            id: durationSettings

            property real breakTime: 15 * 60
            property alias data: timerModel.data
            property real pause: 10 * 60
            property real pomodoro: 25 * 60
            property int repeatBeforeBreak: 2
            property real timer: 0
            property alias title: timerModel.title
        }
        BurnerModel {
            id: burnerModel

            durationSettings: durationSettings
        }
        FileDialogue {
            id: fileDialogue

        }
        Clock {
            id: clock

        }
        Item {
            id: clockFace

            anchors.top: parent.top
            height: parent.width
            width: parent.width

            MouseTracker {
                id: mouseTrackerArea

            }
            StartScreen {
                id: startControls

            }
            TimerScreen {
                id: digitalClock

            }
            Dials {
                id: canvas

                anchors.fill: parent
                burnerModel: burnerModel
                duration: piloramaTimer.duration
                isRunning: piloramaTimer.running
                splitDuration: piloramaTimer.splitDuration
                splitToSequence: true
                timerModel: timerModel
            }
        }
        FaIcon {
            id: preferencesButton

            anchors.left: parent.left
            anchors.top: parent.top
            glyph: "\uf0c9"

            onReleased: {
                stack.push(preferences);
            }
        }
        Sequence {
            id: sequence

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: clockFace.bottom
            anchors.topMargin: 16

            ExternalDrop {
                id: externalDrop

            }
        }
    }
}
