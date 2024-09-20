import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtCore

import "Components"
import "Screens/Preferences"
import "Screens/Timer"

ApplicationWindow {
    id: window
    title: qsTr("Pilorama")

    flags: Qt.FramelessWindowHint

    height: 600
    width: 320
    maximumWidth: width
    minimumWidth: width

    visible: true

    color: "transparent"

    property bool alwaysOnTop: false
    property string clockMode: "start"
    property bool expanded: true
    property bool quitOnClose: false

    // Allow window to be dragged by any part of the window
    MouseArea {
        property variant origin: "1,1"

        anchors.fill: parent

        onPressed: (mouse) => {
            origin = Qt.point(mouse.x, mouse.y)
        }

        onPositionChanged: (mouse) => {
            let delta = Qt.point(mouse.x - origin.x, mouse.y - origin.y)
            window.x += delta.x;
            window.y += delta.y;
        }
    }

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
    // onClockModeChanged: {
    //     canvas.requestPaint();
    // }
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
            height = padding * 2 + timerLayout.height + timer.height;
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
            } else appSettings.darkMode = systemPalette.colorTheme === "Dark";
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
        // property alias showQueue: timer.showQueue
        // property alias soundMuted: notifications.soundMuted
        // property alias splitToSequence: preferences.splitToSequence
        property alias windowHeight: window.height
        property alias windowX: window.x
        property alias windowY: window.y

        onDarkModeChanged: {
            canvas.requestPaint();
        }
        onShowInDockChanged: {
            updateDockVisibility();
        }
        // onSplitToSequenceChanged: {
        //     canvas.requestPaint();
        // }
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

    Rectangle {
        id: container

        color: colors.getColor("bg")

        anchors.fill: parent
        radius: 10
        border {
            color: "#56FFFFFF"
            width: 1
        }

        StackView {
            id: stack

            property int transitionDuration: 750
            property int transitionType: Easing.InOutBack

            anchors.fill: parent
            initialItem: timer

            pushExit: Transition {
                XAnimator {
                    duration: stack.transitionDuration
                    easing.type: stack.transitionType
                    to: stack.width
                }
            }
            pushEnter: Transition {
                XAnimator {
                    duration: stack.transitionDuration
                    easing.type: stack.transitionType
                    from: -stack.width
                    to: 0
                }
            }

            popEnter: Transition {
                XAnimator {
                    duration: stack.transitionDuration
                    easing.type: stack.transitionType
                    from: stack.width
                    to: 0
                }
            }
            popExit: Transition {
                XAnimator {
                    duration: stack.transitionDuration
                    easing.type: stack.transitionType
                    to: -stack.width
                }
            }

            Timer {
                id: timer
            }

            Preferences {
                id: preferences
            }
        }
    }
}
