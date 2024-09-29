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

    property int windowType: Qt.FramelessWindowHint

    flags: windowType

    height: 680
    minimumHeight: 420
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

    onVisibleChanged: {
        if (visible) {
            if (Qt.platform.os === "osx") {
                MacOSController.showInDock();
            }
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
        property string colorTheme: "System"
        property bool darkMode: true
        property alias quitOnClose: window.quitOnClose
        property bool showInDock: false

        property bool audioNotificationsEnabled: true

        onColorThemeChanged: {
            // canvas.requestPaint();
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
            } else appSettings.darkMode = systemPalette.colorTheme === "Dark";
        }

        Component.onCompleted: updateTheme()
        onColorThemeChanged: updateTheme()
        onSystemDarkModeChanged: updateTheme()
    }

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

    // Make application visible when it's activated
    Connections {
        target: appStateHandler

        function onApplicationStateChanged(applicationState) {
            if (applicationState === Qt.ApplicationActive) {
                window.showNormal()
            }
        }
    }


    // Sound notifications
    Notification {
        id: notifications
    }

    // Tray icon
    TrayIcon {
        id: tray
    }

    PiloramaTimer {
        id: globalTimer
    }


    // Main application "window"
    Rectangle {
        id: container

        // Animate dark/light mode change
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        color: colors.getColor("bg")

        anchors.fill: parent
        radius: 10
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

            anchors.top: header.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
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
