import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Controls 2.13
import Qt.labs.settings 1.0

import "Components"
import "Components/Sequence"


ApplicationWindow {
    id: window
    visible: true

    x: 100
    y: 100

    width: 320
    height: 600
    flags: Qt.Window

    minimumHeight: timerLayout.height + padding * 2 + 50
    minimumWidth: timerLayout.width + padding * 2

    maximumWidth: width

    color: colors.getColor("bg")
    title: qsTr("Pilorama")

    Behavior on color { ColorAnimation { duration: 200 } }

    property real padding: 16
    property bool expanded: true

    property bool alwaysOnTop: false
    property bool quitOnClose: true

    property string clockMode: "start"

    SystemPalette{
        id: systemPalette

        property color lightColor: '#ffffff'
        property bool sysemDarkMode: base !== lightColor
        property alias follow: appSettings.followSystemTheme

        onSysemDarkModeChanged: setSystemColors()
        onFollowChanged: setSystemColors()
        Component.onCompleted: setSystemColors()


        function setSystemColors(){
            if(appSettings.followSystemTheme){
                appSettings.darkMode = sysemDarkMode
            }
        }
    }

    onClosing: {
        if(!quitOnClose) {
            close.accepted = false;
            if (Qt.platform.os == "osx") {
                window.hide();
            }
            else {
                window.visibility = ApplicationWindow.Minimized;
            }
        }
    }

    onAlwaysOnTopChanged: {
        alwaysOnTop ? flags = Qt.WindowStaysOnTopHint | Qt.Window : flags = Qt.Window
        requestActivate()
    }

    onClockModeChanged: { canvas.requestPaint() }
    onExpandedChanged: {
        if(expanded === true){
            height = padding * 2 + timerLayout.height + sequence.height
        } else {
            height = padding * 2 + timerLayout.height
        }
    }


    function checkClockMode (){

        if (pomodoroQueue.infiniteMode && globalTimer.running){
            clockMode = "pomodoro"
        } else if (!pomodoroQueue.infiniteMode){
            clockMode = "timer"
        } else {
            clockMode = "start"
        }
    }

    Settings {
        id: appSettings

        property bool darkMode: false
        property bool followSystemTheme: true

        property alias soundMuted: notifications.soundMuted
        property alias splitToSequence: preferences.splitToSequence

        property alias windowX: window.x
        property alias windowY: window.y

        property alias windowHeight: window.height

        property alias alwaysOnTop: window.alwaysOnTop
        property alias quitOnClose: window.quitOnClose
        property alias showQueue: sequence.showQueue

        onDarkModeChanged: { canvas.requestPaint(); }
        onSplitToSequenceChanged: { canvas.requestPaint(); }
    }

    Settings {
        id: durationSettings

        property real timer: 0

        property real pomodoro: 25 * 60
        property real pause: 10 * 60
        property real breakTime: 15 * 60
        property int repeatBeforeBreak: 2

        property alias data: masterModel.data
        property alias title: masterModel.title

        onDataChanged: console.log("Settings data:" + data)

    }

    Colors {
        id: colors
    }

    FontLoader {
        id: localFont;
        source: "./assets/font/Inter.otf"
    }


    MasterModel {
        id: masterModel
        data: data
        title: title
    }

    ModelBurner {
        id: pomodoroQueue
        durationSettings: durationSettings
    }

    TrayIcon {
        id: tray
    }

    NotificationSystem {
        id: notifications
    }

    PiloramaTimer {
        id: globalTimer
    }

    Clock {
        id: clock
    }

    FileDialogue {
        id: fileDialogue
    }

    QtObject {
        id: time
        property real hours: 0
        property real minutes: 0
        property real seconds: 0

        function updateTime() {
            var currentDate = new Date()
            hours = currentDate.getHours()
            minutes = currentDate.getMinutes()
            seconds = currentDate.getSeconds()
        }
    }

    StackView {
        id: stack
        anchors.bottomMargin: 3
        anchors.rightMargin: window.padding
        anchors.leftMargin: window.padding
//        anchors.bottomMargin: window.padding
        anchors.topMargin: window.padding
        anchors.fill: parent

        initialItem: content

        Item {
        id: content

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
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
            }


            SoundButton {
                id: soundButton
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
            }

            PreferencesButton {
                id: preferencesButton
            }


//            PreferencesButton {
//                id: preferencesButton
//                anchors.top: parent.top
//                anchors.topMargin: 0
//                anchors.left: parent.left
//                anchors.leftMargin: 0
//            }

            ExternalDrop {
                id: externalDrop
            }

        }

        Sequence {
            id: sequence
            anchors.top: timerLayout.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 18
        }
        }

        Preferences {
                id: preferences
        }
    }

}






/*##^##
Designer {
    D{i:1;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}D{i:18;anchors_height:200;anchors_width:200;anchors_x:104;anchors_y:54}
D{i:22;anchors_y:486}D{i:16;anchors_height:200;anchors_width:200;anchors_x:104;anchors_y:54}
}
##^##*/

