import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtCore

import "Components"
import "Components/Sequence"

ApplicationWindow {
    id: window
    visible: true

    x: 100
    y: 100

    width: 320
    height: 600
    property bool macTitlebar: Qt.platform.os === "osx"
    property int macTitlebarHeight: macTitlebar ? 20 : 0
    property int macHeaderSpacing: macTitlebar ? 10 : 0
    property int macHeaderTopOffset: macTitlebar ? 7 : 0
    property int macHeaderTotalHeight: macTitlebar ? macTitlebarHeight + macHeaderSpacing : 0
    property int baseWindowFlags: macTitlebar ? (Qt.Window | Qt.FramelessWindowHint) : Qt.Window

    flags: baseWindowFlags

    property real padding: 16

    minimumHeight: timerLayout.height + padding * 2 + 50 + macHeaderTotalHeight
    minimumWidth: timerLayout.width + padding * 2

    maximumWidth: width

    color: colors.getColor("bg")
    title: qsTr("Pilorama")

    Behavior on color { ColorAnimation { duration: 200 } }

    property bool expanded: true

    property bool alwaysOnTop: false
    property bool quitOnClose: false

    property string clockMode: "start"

    Component.onCompleted: {
        updateDockVisibility();
    }

    function updateDockVisibility() {
        if (appSettings.showInDock) {
            MacOSController.showInDock()
        }
        else {
            MacOSController.hideFromDock()
            window.raise()
            window.show()
        }
    }

    SystemPalette{
        id: systemPalette

        property bool sysemDarkMode: Application.styleHints.colorScheme === Qt.ColorScheme.Dark
        property alias colorTheme: appSettings.colorTheme

        onColorThemeChanged: updateTheme()
        onSysemDarkModeChanged: updateTheme()
        Component.onCompleted: updateTheme()

        function updateTheme(){
            if(systemPalette.colorTheme === "System"){
                appSettings.darkMode = sysemDarkMode
            }
            else if (systemPalette.colorTheme === "Dark") {
                appSettings.darkMode = true
            }
            else {
                appSettings.darkMode = false
            }
        }
    }

    onClosing: (close) => {
        if(!quitOnClose) {
            close.accepted = false;
            if (Qt.platform.os === "osx") {
                window.hide();
                if (appSettings.showInDock) {
                    MacOSController.hideFromDock()
                }
            }
            else {
                window.visibility = ApplicationWindow.Minimized;
            }
        }
    }

    onAlwaysOnTopChanged: {
        alwaysOnTop ? flags = Qt.WindowStaysOnTopHint | baseWindowFlags : flags = baseWindowFlags
        requestActivate()
    }

    onClockModeChanged: { canvas.requestPaint() }
    onExpandedChanged: {
        if(expanded === true){
            height = padding * 2 + macHeaderTotalHeight + timerLayout.height + sequence.height
        } else {
            height = padding * 2 + macHeaderTotalHeight + timerLayout.height
        }
    }

    // Allow window to be dragged by any part of the window (macOS frameless)
    MouseArea {
        property point origin: Qt.point(0, 0)

        anchors.fill: parent
        enabled: macTitlebar

        onPositionChanged: (mouse) => {
            if (mouse.buttons & Qt.LeftButton) {
                const delta = Qt.point(mouse.x - origin.x, mouse.y - origin.y)
                window.x += delta.x
                window.y += delta.y
            }
        }
        onPressed: (mouse) => {
            origin = Qt.point(mouse.x, mouse.y)
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
        property string colorTheme: "System"
        property bool showInDock: false
        property bool showPauseUI: true
        property bool showOnSegmentStart: false

        property url defaultSound: "qrc:assets/sound/drum_roll.wav"
        property bool soundMuted: false
        property url soundPath: defaultSound
        property alias splitToSequence: preferences.splitToSequence

        property alias windowX: window.x
        property alias windowY: window.y

        property alias windowHeight: window.height

        property alias alwaysOnTop: window.alwaysOnTop
        property alias quitOnClose: window.quitOnClose
        property alias showQueue: sequence.showQueue

        onDarkModeChanged: { canvas.requestPaint(); }
        onSplitToSequenceChanged: { canvas.requestPaint(); }
        onShowInDockChanged: { updateDockVisibility(); }
    }

    SoundSettings {
        id: soundSettings
        settings: appSettings
        defaultSound: appSettings.defaultSound
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
        source: "qrc:/assets/font/Inter.otf"
    }

    FontLoader {
        id: iconFont;
        source: "qrc:/assets/font/pilorama.ttf"
    }

    FontLoader {
        id: awesomeFont
        source: "qrc:/assets/font/fa-solid.otf"
    }

    MasterModel {
        id: masterModel
        data: data
        title: title
    }

    ModelBurner {
        id: pomodoroQueue // TODO rename the ID
        durationSettings: durationSettings
    }

    TrayIcon {
        id: tray
    }

    NotificationSystem {
        id: notifications
        settings: appSettings
        soundSettings: soundSettings
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

    Item {
        id: windowHeader

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: macTitlebarHeight
        visible: macTitlebar
        z: 1

        Item {
            id: headerContent

            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.topMargin: 2
            anchors.bottomMargin: 2

            Image {
                id: headerLogo
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: macHeaderTopOffset
                height: 16
                fillMode: Image.PreserveAspectFit
                source: appSettings.darkMode
                        ? "qrc:/assets/img/white-logo.svg"
                        : "qrc:/assets/img/dark-logo.svg"
                visible: macTitlebar
            }

            MacWindowControls {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: macHeaderTopOffset
                visible: macTitlebar
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: headerLogo.bottom
                anchors.topMargin: macHeaderSpacing
                height: 0.5
                color: colors.getColor("light")
                visible: macTitlebar
            }
        }
    }

    StackView {
        id: stack
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: windowHeader.bottom
        anchors.topMargin: macHeaderSpacing

        initialItem: content

        popEnter: Transition {
            XAnimator {
                from: stack.width
                to: 16
                duration: 250
                easing.type: Easing.InOutCubic
            }
        }

        popExit: Transition {
            XAnimator {
                from: 0
                to: -stack.width
                duration: 250
                easing.type: Easing.InOutCubic
            }
        }

        pushExit: Transition {
            XAnimator {
                from: 16
                to: stack.width
                duration: 250
                easing.type: Easing.InOutCubic
            }
        }

        pushEnter: Transition {
            XAnimator {
                from: -stack.width
                to: 0
                duration: 250
                easing.type: Easing.InOutCubic
            }
        }

        Item {
        id: content

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 16

        Item {
            id: timerLayout
            width: parent.width
            height: width
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top

            Dials {
                id: canvas
                anchors.fill: parent
                duration: globalTimer.duration
                splitDuration: globalTimer.splitDuration
                isRunning: globalTimer.running
                splitToSequence: appSettings.splitToSequence
                pomodoroQueue: pomodoroQueue
                masterModel: masterModel
                colors: colors
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

            Icon {
                id: soundButton
                glyph: notifications.soundMuted ? "\uea09" : "\uea06"
                anchors.top: parent.top
                anchors.right: parent.right

                onReleased: {
                     notifications.toggleSoundNotifications();
                }
            }


            Icon {
                id: preferencesButton
                glyph: "\uea04"

                anchors.top: parent.top
                anchors.left: parent.left

                onReleased: {
                    stack.push(preferences)
                }
            }


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
                appSettings: appSettings
                soundSettings: soundSettings
        }
    }

}
