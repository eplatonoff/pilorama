import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtCore

import "Components"
import "Screens/Preferences"
import "Screens/Timer"

ApplicationWindow {
    id: window

    property bool alwaysOnTop: false
    property string clockMode: "start"
    property bool expanded: true
    property bool quitOnClose: false
    property int windowType: Qt.FramelessWindowHint

    function checkClockMode() {
        if (piloramaTimer.running) {
            clockMode = "pomodoro";
        } else {
            clockMode = "timer";
        }
    }

    color: "transparent"
    flags: windowType
    height: 700
    maximumWidth: width
    minimumHeight: 550
    minimumWidth: width
    title: qsTr("Pilorama")
    visible: true
    width: 320

    onAlwaysOnTopChanged: {
        alwaysOnTop ? flags = Qt.WindowStaysOnTopHint | windowType : flags = windowType;
        requestActivate();
    }
    onClosing: close => {
        if (!quitOnClose) {
            close.accepted = false;
            if (Qt.platform.os === "osx") {
                window.hide();
                if (!appSettings.showInDock) {
                    MacOSController.hideFromDock();
                }
            } else {
                window.visibility = ApplicationWindow.Minimized;
            }
        }
    }
    onVisibleChanged: {
        if (visible) {
            if (Qt.platform.os === "osx") {
                MacOSController.showInDock();
            }
        }
    }

    // Allow window to be dragged by any part of the window
    MouseArea {
        property variant origin: "1,1"

        anchors.fill: parent

        onPositionChanged: mouse => {
            let delta = Qt.point(mouse.x - origin.x, mouse.y - origin.y);
            window.x += delta.x;
            window.y += delta.y;
        }
        onPressed: mouse => {
            origin = Qt.point(mouse.x, mouse.y);
        }
    }

    // Load fonts
    FontLoader {
        id: localFont

        source: "qrc:/assets/font/inter.otf"
    }
    FontLoader {
        id: iconFont

        source: "qrc:/assets/font/pilorama.ttf"
    }
    FontLoader {
        id: awesomeFont

        source: "qrc:/assets/font/fa-solid.otf"
    }

    // Load colors schemes
    Colors {
        id: colors

    }

    // Define settings
    Settings {
        id: appSettings

        property alias alwaysOnTop: window.alwaysOnTop
        property bool audioNotificationsEnabled: true
        property string colorTheme: "System"
        property bool darkMode: true
        property alias quitOnClose: window.quitOnClose
        property bool showInDock: false

        onColorThemeChanged: {
            canvas.requestPaint();
        }
    }

    // System theme provider
    SystemPalette {
        id: systemPalette

        property alias colorTheme: appSettings.colorTheme
        property bool systemDarkMode: (Application.styleHints.colorScheme === Qt.ColorScheme.Dark)

        function updateTheme() {
            if (systemPalette.colorTheme === "System") {
                appSettings.darkMode = systemDarkMode;
            } else
                appSettings.darkMode = systemPalette.colorTheme === "Dark";
        }

        Component.onCompleted: updateTheme()
        onColorThemeChanged: updateTheme()
        onSystemDarkModeChanged: updateTheme()
    }

    // Make application visible when it's activated
    Connections {
        function onApplicationStateChanged(applicationState) {
            if (applicationState === Qt.ApplicationActive) {
                window.showNormal();
            }
        }

        target: appStateHandler
    }

    // Sound notifications
    Notification {
        id: notifications

    }

    // Tray icon
    TrayIcon {
        id: tray

        burnerModel: timer.getBurnerModel()
        timerModel: timer.getTimerModel()
    }
    PiloramaTimer {
        id: piloramaTimer

        burnerModel: timer.getBurnerModel()
        canvas: timer.getCanvas()
        mouseTrackerArea: timer.getMouseTrackerArea()
        sequence: timer.getSequence()
    }
    QtObject {
        id: time

        property real hours: 0
        property real minutes: 0
        property real seconds: 0

        function updateTime() {
            const currentDate = new Date();
            hours = currentDate.getHours();
            minutes = currentDate.getMinutes();
            seconds = currentDate.getSeconds();
        }
    }

    // Main application "window"
    Rectangle {
        id: container

        anchors.fill: parent
        color: colors.getColor("bg")
        radius: 10

        // Animate dark/light mode change
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        border {
            color: colors.getColor("light")
            width: 0.5
        }
        Header {
            id: header

        }
        StackView {
            id: stack

            property int transitionDuration: 250
            property int transitionType: Easing.OutQuad

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.topMargin: 16
            initialItem: timer

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
            pushEnter: Transition {
                XAnimator {
                    duration: stack.transitionDuration
                    easing.type: stack.transitionType
                    from: -stack.width
                    to: 0
                }
            }
            pushExit: Transition {
                XAnimator {
                    duration: stack.transitionDuration
                    easing.type: stack.transitionType
                    to: stack.width
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
