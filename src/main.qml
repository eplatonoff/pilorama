import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import Qt.labs.settings 1.0

import "Components"
import "Components/Sequence"


ApplicationWindow {
    id: window
    visible: true
    width: 320
    height: 650
    minimumHeight: 320

    maximumWidth: width
    minimumWidth: width

    color: appSettings.darkMode ? colors.bgDark : colors.bgLight
    title: qsTr("qml timer")

    property string clockMode: "start"

    onClockModeChanged: { canvas.requestPaint()}

    function checkClockMode (){
        // temporary Settings
        appSettings.splitToSequence = true
        durationSettings.pomodoro = 900
        durationSettings.pause = 300
        durationSettings.breakTime = 600
        durationSettings.repeatBeforeBreak = 2

        if (pomodoroQueue.infiniteMode && globalTimer.running){
            clockMode = "pomodoro"
        } else if (!pomodoroQueue.infiniteMode){
            clockMode = "timer"
        } else {
            clockMode = "start"
        }
    }

    Item {
        id: content

        anchors.rightMargin: 16
        anchors.leftMargin: 16
        anchors.bottomMargin: 16
        anchors.topMargin: 16
        anchors.fill: parent

        Item {
            id: timerLayout
            width: 288
            height: width
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top

            Dials {
                id: canvas

                MouseTracker {
                    id: mouseArea}
            }

            StartScreen {
                id: startControls
            }

            TimerScreen {
                id: digitalClock
            }
        }

        DarkModeButton {
            id: darkModeButton
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
        }

        PrefsButton {
            id: prefsButton
            anchors.bottom: timerLayout.bottom
            anchors.bottomMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
        }

        SoundButton {
            id: soundButton
            x: -16
            y: 486
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: timerLayout.bottom
            anchors.bottomMargin: 0
        }

        Rectangle {
            id: layoutDivider
            height: 1
            width: parent.width
            color: colors.get("light")
            anchors.top: timerLayout.bottom
            anchors.topMargin: 18

        }

        Sequence {
            id: sequence
            anchors.top: layoutDivider.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 0

        }


    }

    TrayIcon {
        id: tray
    }

    NotificationSystem {
        id: notifications
    }


    PomodoroModel {
        id: pomodoroQueue
        durationSettings: durationSettings
    }

    SequenceModel {
        id: sequenceModel
        data: data
    }



    Settings {
        id: durationSettings

        property real timer: 0

        property real pomodoro: 25 * 60
        property real pause: 10 * 60
        property real breakTime: 15 * 60
        property int repeatBeforeBreak: 2

        property alias sequenceData: sequenceModel.data

        onSequenceDataChanged: console.log("Reloaded:" + sequenceData)

    }

    Settings {
        id: appSettings

        property bool darkMode: false
        property alias soundMuted: notifications.soundMuted
        property bool splitToSequence: true

        onDarkModeChanged: { canvas.requestPaint(); }
        onSplitToSequenceChanged: { canvas.requestPaint(); }
    }

    Colors {
        id: colors
    }

    QTimer {
        id: globalTimer
    }

    QtObject {
        id: time
        property real hours: 0
        property real minutes: 0
        property real seconds: 0

        function updateTime(){
            var currentDate = new Date()
            hours = currentDate.getHours()
            minutes = currentDate.getMinutes()
            seconds = currentDate.getSeconds()
        }
    }




}






/*##^##
Designer {
    D{i:6;anchors_width:200}D{i:2;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}
D{i:7;anchors_height:200;anchors_width:200;anchors_x:44;anchors_y:55}D{i:8;anchors_height:200;anchors_width:200;anchors_x:44;anchors_y:55}
D{i:9;anchors_height:40;anchors_x:16;anchors_y:16}D{i:10;anchors_width:200}D{i:11;anchors_height:200;anchors_width:200;anchors_x:50;anchors_y:55}
D{i:1;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}D{i:12;anchors_height:40;anchors_width:200;anchors_x:99;anchors_y:54;invisible:true}
D{i:13;anchors_height:200;anchors_width:200;anchors_x:99;anchors_y:54}D{i:14;anchors_height:200;anchors_width:200;anchors_x:99;anchors_y:54}
D{i:15;anchors_height:200;anchors_width:200;anchors_x:104;anchors_y:54;invisible:true}
D{i:16;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0;invisible:true}
D{i:17;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0;invisible:true}
D{i:18;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0;invisible:true}
D{i:19;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0;invisible:true}
}
##^##*/

