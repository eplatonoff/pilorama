import QtQuick
import Qt.labs.platform


SystemTrayIcon {
    id: tray
    visible: true
    icon.mask: globalTimer.running ? false : true
    icon.source: iconURL()
    icon.name: qsTr("Pilorama")
    tooltip : window.title
    property string appTitle: window.title
    property string messageText: ""
    property string messageTitle: ""
    property string menuItemText: checkMenuItemText()
    property string soundItemText: "Turn sound " + checkSoundItemText()


    // TODO refactor
    property real remainingTime: pomodoroQueue.infiniteMode ? globalTimer.splitDuration : globalTimer.duration
    property real totalDuration: pomodoroQueue.infiniteMode ? pomodoroQueue.currentDurationBound : globalTimer.durationBound

    property real trayUpdateCounter: 0

    Component.onCompleted: {
       trayUpdateCounter = remainingTime
    }

    onMessageClicked: popUp()
    onActivated: (reason) => {
        if(reason === SystemTrayIcon.DoubleClick){ popUp(); !menu.visible}
    }

    onRemainingTimeChanged: {
        const diff = Math.abs(remainingTime - trayUpdateCounter);
        if (diff >= computeUpdateInterval()) {
            icon.source = iconURL(
                Math.round((remainingTime * 3600 / totalDuration) / 10) * 10
            )
            trayUpdateCounter = remainingTime
        }
    }

    function checkMenuItemText() {
        if (globalTimer.running && pomodoroQueue.infiniteMode) {
            return "Reset Timer"
        } else {
            return "Start Sequence"
        }
    }

    function checkSoundItemText() {
        if (notifications.soundMuted) {
            return "on"
        } else {
            return "off"
        }
    }

    function iconURL(renderSecs = 0)
    {
        if (!globalTimer.running || renderSecs === 0 || renderSecs === Infinity || isNaN(renderSecs))
            if (systemPalette.sysemDarkMode) {
                return 'qrc:/assets/tray/static-night.svg';
            } else {
                return 'qrc:/assets/tray/static-day.svg'
            }

        const color = pomodoroQueue.infiniteMode ? colors.getThemeColor(masterModel.get(pomodoroQueue.first().id).color) : colors.getThemeColor("dark");
        const placeholderColor = colors.getThemeColor("light")

        return "image://tray_icon_provider/" + color + "_" + placeholderColor + "_" + renderSecs;
    }

    function notificationIconURL() {
        const color = pomodoroQueue.infiniteMode ?
                colors.getThemeColor(masterModel.get(pomodoroQueue.first().id).color) :
                colors.getThemeColor("dark");
        return "image://notification_dot_provider/" + color;
    }

    function computeUpdateInterval() {
        return totalDuration <= 120 ? 2 : (totalDuration <= 600 ? 5 : 10);
    }

    function pad(value) {
        if (value < 10) {return "0" + value
        } else {return value}
    }

    function updateTime() {
        let h = Math.trunc(remainingTime / 3600)
        let hour = h > 0 ? h + ":" : ""
        let min = pad(Math.trunc(remainingTime / 60) - h * 60)
        let sec = pad(Math.trunc(remainingTime % 60))
        return "Time left: " + hour + min + ":" + sec
    }

    function send(name){
        var title
        var message
        var showfor

        if (name) {
            title  = name + " started"
            message = "Duration: " + masterModel.get(pomodoroQueue.first().id).duration / 60 +
                    " min.  Ends at " + clock.getNotificationTime().clock
            showfor = 5000
        } else {
            title = "Time ran out"
            message = "Duration: " + globalTimer.durationBound / 60 + " min"
            showfor = 10000
        }

        if (Qt.platform.os === "osx") {
            MacOSController.showNotification(title, message, notificationIconURL())
        } else {
            showMessage(title, message, iconURL(), showfor)
        }
    }

    function popUp(){
       if (appSettings.showInDock) { // TODO don't use global variable
            MacOSController.showInDock()
       }

       window.show()
       window.raise()
    }

    menu: Menu {

       MenuItem {
           text: updateTime()
           onTriggered: {window.active}
           visible: globalTimer.running
       }

        MenuSeparator {
            visible: globalTimer.running
        }

        MenuItem {
            text: tray.menuItemText
            onTriggered: {
                if (globalTimer.running) {

                    pomodoroQueue.infiniteMode = false;
                    pomodoroQueue.clear();

                    mouseArea._prevAngle = 0
                    mouseArea._totalRotatedSecs = 0

                    globalTimer.duration = 0
                    globalTimer.stop()

                    window.clockMode = "start"

                    notifications.stopSound();
                    sequence.setCurrentItem(-1)

                } else {
                    window.clockMode = "pomodoro"
                    pomodoroQueue.infiniteMode = true
                    globalTimer.start()
                    notifications.sendFromItem(pomodoroQueue.first())
                }

            }
        }
        MenuItem {
            text: tray.soundItemText
            onTriggered: {
                notifications.toggleSoundNotifications();
            }
        }
        MenuItem {
            text: qsTr("Preferences")
            onTriggered: {
               popUp()
               if (stack.currentItem === content) {
                   stack.push(preferences)
               }
            }
        }

        MenuSeparator {}

        MenuItem {
            text: "Show " + window.title
            onTriggered: {
                popUp()
            }
        }

        MenuItem {
            text: qsTr("Quit")
            onTriggered: {
                window.close()
                Qt.quit()
            }
        }
    }

}
