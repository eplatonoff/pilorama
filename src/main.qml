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
    height: padding * 2 + timerLayout.height + layoutDivider.height + layoutDivider.padding + sequence.height
    minimumHeight: 320

    maximumWidth: width
    minimumWidth: width

    color: appSettings.darkMode ? colors.bgDark : colors.bgLight
    title: qsTr("qml timer")

    property real padding: 16
    property bool expanded: true

    property string clockMode: "start"

    onClockModeChanged: {canvas.requestPaint()}
    onExpandedChanged: {
        if(expanded === true){
            height = padding * 2 + timerLayout.height + layoutDivider.height + layoutDivider.padding + sequence.height
        } else {
            height = padding * 2 + timerLayout.height
        }
    }


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

    Colors {
        id: colors
    }

    Item {
        id: content

        anchors.rightMargin: window.padding
        anchors.leftMargin: window.padding
        anchors.bottomMargin: window.padding
        anchors.topMargin: window.padding
        anchors.fill: parent

        Item {
            id: timerLayout
            width: parent.width
            height: width
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top

            Dials {
                id: canvas

            }

            MouseTracker {
                id: mouseArea
            }

            StartScreen {
                id: startControls
            }

            TimerScreen {
                id: digitalClock
            }

            DarkModeButton {
                id: darkModeButton
                x: 238
                y: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
            }

            PrefsButton {
                id: prefsButton
                x: 238
                y: 0
                anchors.bottom: timerLayout.bottom
                anchors.bottomMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
            }

            SoundButton {
                id: soundButton
                x: 0
                y: 486
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.bottom: timerLayout.bottom
                anchors.bottomMargin: 0
            }
        }

        Rectangle {
            id: layoutDivider
            height: 1
            width: parent.width
            color: colors.getColor("light")
            anchors.top: timerLayout.bottom
            anchors.topMargin: padding

            property real padding: 18

        }

        Sequence {
            id: sequence
            anchors.top: layoutDivider.bottom
        }
    }



    MasterModel {
        id: masterModel
        data: data
    }

    ModelBurner {
        id: pomodoroQueue
        durationSettings: durationSettings
    }

//    PomodoroModel {
//        id: pomodoroQueue
//        durationSettings: durationSettings
//    }

    IconGenerator {
        id: pixmap
    }

    TrayIcon {
        id: tray
    }

    NotificationSystem {
        id: notifications
    }





    Settings {
        id: durationSettings

        property real timer: 0

        property real pomodoro: 25 * 60
        property real pause: 10 * 60
        property real breakTime: 15 * 60
        property int repeatBeforeBreak: 2

        property alias masterData: masterModel.data

        onMasterDataChanged: console.log("Reloaded:" + masterData)

    }

    Settings {
        id: appSettings

        property bool darkMode: false
        property alias soundMuted: notifications.soundMuted
        property bool splitToSequence: true

        onDarkModeChanged: { canvas.requestPaint(); pixmap.requestPaint() }
        onSplitToSequenceChanged: { canvas.requestPaint(); }
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
    D{i:1;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}D{i:16;anchors_height:200;anchors_width:200;anchors_x:104;anchors_y:54;invisible:true}
D{i:18;anchors_height:200;anchors_width:200;anchors_x:104;anchors_y:54;invisible:true}
}
##^##*/

