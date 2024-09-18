import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtCore

import "Components"
import "Components/Sequence"
import "Screens/Preferences"

ApplicationWindow {
    id: window

    property bool alwaysOnTop: false
    property string clockMode: "start"
    property bool expanded: true
    property bool quitOnClose: false

    function checkClockMode() {
        if (pomodoroQueue.infiniteMode && globalTimer.running) {
            clockMode = "pomodoro";
        } else if (!pomodoroQueue.infiniteMode) {
            clockMode = "timer";
        } else {
            clockMode = "start";
        }
    }
    function updateDockVisibility() {
        if (appSettings.showInDock) {
            MacOSController.showInDock();
        } else {
            MacOSController.hideFromDock();
            window.raise();
            window.show();
        }
    }

    color: colors.getColor("bg")
    flags: Qt.Window
    height: 600
    maximumWidth: width
    minimumHeight: timerLayout.height + 16 * 2 + 50
    minimumWidth: timerLayout.width + 16 * 2
    title: qsTr("Pilorama")
    visible: true
    width: 320
    x: 100
    y: 100

    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }

    Component.onCompleted: {
        updateDockVisibility();
    }
    onAlwaysOnTopChanged: {
        alwaysOnTop ? flags = Qt.WindowStaysOnTopHint | Qt.Window : flags = Qt.Window;
        requestActivate();
    }
    onClockModeChanged: {
        canvas.requestPaint();
    }
    onClosing: close => {
        if (!quitOnClose) {
            close.accepted = false;
            if (Qt.platform.os === "osx") {
                window.hide();
                if (appSettings.showInDock) {
                    MacOSController.hideFromDock();
                }
            } else {
                window.visibility = ApplicationWindow.Minimized;
            }
        }
    }
    onExpandedChanged: {
        if (expanded === true) {
            height = padding * 2 + timerLayout.height + sequence.height;
        } else {
            height = padding * 2 + timerLayout.height;
        }
    }

    SystemPalette {
        id: systemPalette

        property alias colorTheme: appSettings.colorTheme
        property bool sysemDarkMode: Application.styleHints.colorScheme === Qt.ColorScheme.Dark

        function updateTheme() {
            if (systemPalette.colorTheme === "System") {
                appSettings.darkMode = sysemDarkMode;
            } else if (systemPalette.colorTheme === "Dark") {
                appSettings.darkMode = true;
            } else {
                appSettings.darkMode = false;
            }
        }

        Component.onCompleted: updateTheme()
        onColorThemeChanged: updateTheme()
        onSysemDarkModeChanged: updateTheme()
    }
    Settings {
        id: appSettings

        property alias alwaysOnTop: window.alwaysOnTop
        property string colorTheme: "System"
        property bool darkMode: false
        property alias quitOnClose: window.quitOnClose
        property bool showInDock: false
        property alias showQueue: sequence.showQueue
        property alias soundMuted: notifications.soundMuted
        property alias splitToSequence: preferences.splitToSequence
        property alias windowHeight: window.height
        property alias windowX: window.x
        property alias windowY: window.y

        onDarkModeChanged: {
            canvas.requestPaint();
        }
        onShowInDockChanged: {
            updateDockVisibility();
        }
        onSplitToSequenceChanged: {
            canvas.requestPaint();
        }
    }
    Settings {
        id: durationSettings

        property real breakTime: 15 * 60
        property alias data: masterModel.data
        property real pause: 10 * 60
        property real pomodoro: 25 * 60
        property int repeatBeforeBreak: 2
        property real timer: 0
        property alias title: masterModel.title
    }
    Colors {
        id: colors

    }
    FontLoader {
        id: localFont

        source: "qrc:/assets/font/Inter.otf"
    }
    FontLoader {
        id: iconFont

        source: "qrc:/assets/font/pilorama.ttf"
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
            var currentDate = new Date();
            hours = currentDate.getHours();
            minutes = currentDate.getMinutes();
            seconds = currentDate.getSeconds();
        }
    }
    StackView {
        id: stack

        anchors.fill: parent
        initialItem: content

        popEnter: Transition {
            XAnimator {
                duration: 250
                easing.type: Easing.InOutCubic
                from: stack.width
                to: 16
            }
        }
        popExit: Transition {
            XAnimator {
                duration: 250
                easing.type: Easing.InOutCubic
                from: 0
                to: -stack.width
            }
        }
        pushEnter: Transition {
            XAnimator {
                duration: 250
                easing.type: Easing.InOutCubic
                from: -stack.width
                to: 0
            }
        }
        pushExit: Transition {
            XAnimator {
                duration: 250
                easing.type: Easing.InOutCubic
                from: 16
                to: stack.width
            }
        }

        Item {
            id: content

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 16
            anchors.right: parent.right
            anchors.top: parent.top

            Item {
                id: timerLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: parent.width
                width: parent.width

                Dials {
                    id: canvas

                    anchors.fill: parent
                    colors: colors
                    duration: globalTimer.duration
                    isRunning: globalTimer.running
                    masterModel: masterModel
                    pomodoroQueue: pomodoroQueue
                    splitDuration: globalTimer.splitDuration
                    splitToSequence: appSettings.splitToSequence
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

                    anchors.right: parent.right
                    anchors.top: parent.top
                    glyph: notifications.soundMuted ? "\uea09" : "\uea06"

                    onReleased: {
                        notifications.toggleSoundNotifications();
                    }
                }
                Icon {
                    id: preferencesButton

                    anchors.left: parent.left
                    anchors.top: parent.top
                    glyph: "\uea04"

                    onReleased: {
                        stack.push(preferences);
                    }
                }
                ExternalDrop {
                    id: externalDrop

                }
            }
            Sequence {
                id: sequence

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: timerLayout.bottom
                anchors.topMargin: 18
            }
        }
        Preferences {
            id: preferences
        }
    }
}
