import QtQuick
import Qt.labs.platform

SystemTrayIcon {
    id: tray

    property string appTitle: window.title
    // property string messageText: ""
    // property string messageTitle: ""
    // property string menuItemText: checkMenuItemText()
    property string soundItemText: appSettings.audioNotificationsEnabled ? "Mute" : "Unmute"

    // function checkMenuItemText() {
    //     if (globalTimer.running && pomodoroQueue.infiniteMode) {
    //         return "Reset Timer"
    //     } else {
    //         return "Start Sequence"
    //     }
    // }
    //
    // function iconDialMin() {
    //     var precision = 120
    //     var y = Math.abs(dialTime) + precision / 2;
    //     y = y - y % precision;
    //     return y / 60
    // }
    //
    // function messageIcon() {
    //     if (systemPalette.sysemDarkMode) {
    //         return 'qrc:/assets/tray/static-night.svg';
    //     } else {
    //         return 'qrc:/assets/tray/static-day.svg'
    //     }
    // }
    //
    function iconURL() {
        // if (!globalTimer.running)
        return 'qrc:/assets/tray/static.svg';
    }

    icon.mask: globalTimer.running ? false : true
    icon.name: qsTr("Pilorama")
    icon.source: iconURL()
    tooltip: window.title
    visible: true

    //     const color = pomodoroQueue.infiniteMode ? colors.getThemeColor(masterModel.get(pomodoroQueue.first().id).color) : colors.getThemeColor("dark");
    //     const placeholderColor = colors.getThemeColor("light")
    //
    //     const renderSecs = Math.round(dialTime / 10) * 10;
    //
    //     return "image://tray_icon_provider/" + color + "_" + placeholderColor + "_" + renderSecs;
    // }
    //
    // function setDialTime() {
    //     var t
    //     if (!pomodoroQueue.infiniteMode) {
    //         t = globalTimer.duration * 3600 / globalTimer.durationBound
    //         dialTime = globalTimer.duration ? t : 0;
    //     } else {
    //         t = pomodoroQueue.first().duration * 3600 / masterModel.get(pomodoroQueue.first().id).duration
    //         dialTime = pomodoroQueue.first() ? t : 0;
    //     }
    //
    // }
    //
    // function setTime() {
    //     runningTime = pomodoroQueue.infiniteMode ? globalTimer.splitDuration : globalTimer.duration
    //     setDialTime()
    //     updateTime()
    // }
    //
    // function pad(value) {
    //     if (value < 10) {
    //         return "0" + value
    //     } else {
    //         return value
    //     }
    // }
    //
    // function updateTime() {
    //     let h = Math.trunc(runningTime / 3600)
    //     let hour = h > 0 ? h + ":" : ""
    //     let min = pad(Math.trunc(runningTime / 60) - Math.trunc(runningTime / 3600) * 60)
    //     let sec = pad(Math.trunc(runningTime % 60))
    //     return "Time left: " + hour + min + ":" + sec
    // }
    //
    // function send(name) {
    //     var title
    //     var message
    //     var showfor
    //
    //     if (name) {
    //         title = name + " started"
    //         message = "Duration: " + masterModel.get(pomodoroQueue.first().id).duration / 60 +
    //             " min.  Ends at " + clock.getNotificationTime().clock
    //         showfor = 5000
    //     } else {
    //         title = "Time ran out"
    //         message = "Duration: " + globalTimer.durationBound / 60 + " min"
    //         showfor = 10000
    //     }
    //     showMessage(title, message, iconURL(), showfor)
    // }

    menu: Menu {
        // MenuItem {
        //     text: updateTime()
        //     onTriggered: {window.active}
        //     visible: globalTimer.running
        // }
        //
        //  MenuSeparator {
        //      visible: globalTimer.running
        //  }

        // MenuItem {
        //     text: tray.menuItemText
        //     onTriggered: {
        //         if (globalTimer.running) {
        //
        //             pomodoroQueue.infiniteMode = false;
        //             pomodoroQueue.clear();
        //
        //             mouseArea._prevAngle = 0
        //             mouseArea._totalRotatedSecs = 0
        //
        //             globalTimer.duration = 0
        //             globalTimer.stop()
        //
        //             window.clockMode = "start"
        //
        //             notifications.stopSound();
        //             sequence.setCurrentItem(-1)
        //
        //         } else {
        //             window.clockMode = "pomodoro"
        //             pomodoroQueue.infiniteMode = true
        //             globalTimer.start()
        //             notifications.sendFromItem(pomodoroQueue.first())
        //         }
        //
        //     }
        // }
        MenuItem {
            text: tray.soundItemText

            onTriggered: {
                appSettings.audioNotificationsEnabled = !appSettings.audioNotificationsEnabled;
            }
        }
        MenuItem {
            text: qsTr("Preferences")

            onTriggered: {
                window.showNormal();
                if (stack.currentItem === timer) {
                    stack.push(preferences);
                }
            }
        }
        MenuSeparator {
        }
        MenuItem {
            text: "Show " + window.title

            onTriggered: {
                window.showNormal();
            }
        }
        MenuItem {
            text: qsTr("Quit")

            onTriggered: {
                window.close();
                Qt.quit();
            }
        }
    }

    onActivated: reason => {
        if (reason === SystemTrayIcon.DoubleClick) {
            window.showNormal();
            !menu.visible;
        }
    }
    //
    //
    // property real dialTime: 0
    // property real runningTime: 0

    onMessageClicked: window.showNormal()
}
