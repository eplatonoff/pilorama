import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import Qt.labs.settings 1.0

import "Components"

Window {
    id: window
    visible: true
    width: 300
    height: 300

    maximumWidth: width
    maximumHeight: height

    minimumWidth: width
    minimumHeight: height

    color: appSettings.darkMode ? colors.bgDark : colors.bgLight
    title: qsTr("qml timer")

    property string clockMode: "start"

    onClockModeChanged: { canvas.requestPaint()}

    function checkClockMode (){
        if (pomodoroQueue.infiniteMode && globalTimer.running){
            clockMode = "pomodoro"
        } else if (!pomodoroQueue.infiniteMode){
            clockMode = "timer"
        } else {
            clockMode = "start"
        }
    }

    StackView {
        id: content
        initialItem: timerLayout

        anchors.rightMargin: 16
        anchors.leftMargin: 16
        anchors.bottomMargin: 16
        anchors.topMargin: 16
        anchors.fill: parent

        Item {
            id: timerLayout

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

        Preferences {
            id: prefsLayout
            visible: false
        }

    }

    NotificationSystem {
        id: notifications
    }


    SoundButton {
        id: soundButton
        y: 16
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
    }

    PrefsButton {
        id: prefsButton
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.topMargin: 0
    }

    DarkModeButton {
        id: darkModeButton
        x: 16
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
    }

    PomodoroModel {
        id: pomodoroQueue
        durationSettings: durationSettings
    }

    Settings {
        id: durationSettings

        property real pomodoro: 25 * 60
        property real pause: 10 * 60
        property real breakTime: 15 * 60
        property int repeatBeforeBreak: 2
    }

    Settings {
        id: appSettings

        property bool darkMode: false
        property alias soundMuted: notifications.soundMuted
        property bool splitToSequence: false

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
    D{i:6;anchors_width:200;invisible:true}D{i:2;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}
D{i:7;anchors_width:200;invisible:true}D{i:1;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0;invisible:true}
D{i:8;anchors_height:200;anchors_width:200;anchors_x:50;anchors_y:55}D{i:9;anchors_height:40;anchors_x:99;anchors_y:54;invisible:true}
D{i:10;anchors_height:40;anchors_x:16;anchors_y:16;invisible:true}D{i:11;anchors_height:200;anchors_width:200;anchors_x:44;anchors_y:55}
D{i:13;anchors_height:200;anchors_width:200;anchors_x:99;anchors_y:54}D{i:14;anchors_x:99;anchors_y:54}
D{i:15;anchors_x:104;anchors_y:54;invisible:true}D{i:16;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0;invisible:true}
D{i:17;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0;invisible:true}
}
##^##*/

