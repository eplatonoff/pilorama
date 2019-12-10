import QtQuick 2.0
import Qt.labs.platform 1.1

SystemTrayIcon {
    id: tray
    visible: true
    iconSource: iconURL()
    iconName: qsTr("test")
    tooltip : window.title
    property string appTitle: "QML Timer"
    property string messageText: ""
    property string menuItemText: checkMenuItemText()
    property string soundItemText: "Turn sound " + checkSoundItemText()

    property real dialTime: 0
    property real runningTime: 0

    onMessageClicked: popUp()
    onMessageTextChanged: showMessage(tray.appTitle, tray.messageText)


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

    function iconDialMin() {
        var precision = 120
        var y = Math.abs(dialTime) + precision / 2;
        y = y - y % precision;
        return y / 60
    }

    function iconURL()
    {
        if (!globalTimer.running)
            if (systemPalette.sysemDarkMode) {
                return './assets/tray/static-night.svg';
            } else {
                return './assets/tray/static-day.svg'
            }

        const color = pomodoroQueue.infiniteMode ? colors.getThemeColor(masterModel.get(pomodoroQueue.first().id).color) : colors.getThemeColor("dark");
        const placeholderColor = colors.getThemeColor("light")

        const renderSecs = Math.round(dialTime / 10) * 10;

        return "image://tray_icon_provider/" + color + "_" + placeholderColor + "_" + renderSecs;
    }

    function setDialTime() {
        var t
        if(!pomodoroQueue.infiniteMode) {
            t = globalTimer.duration * 3600 / globalTimer.durationBound
            dialTime = globalTimer.duration ? t : 0;
        } else {
            t = pomodoroQueue.first().duration * 3600 / masterModel.get(pomodoroQueue.first().id).duration
            dialTime = pomodoroQueue.first() ? t : 0;
        }

    }

    function setTime() {
        runningTime = pomodoroQueue.infiniteMode ? globalTimer.splitDuration : globalTimer.duration
        setDialTime()
        updateTime()
    }

    function pad(value) {
        if (value < 10) {return "0" + value
        } else {return value}
    }

    function updateTime() {
        let h = Math.trunc(runningTime / 3600)
        let hour = h > 0 ? h + ":" : ""
        let min = pad(Math.trunc(runningTime / 60) - Math.trunc(runningTime / 3600) * 60)
        let sec = pad(Math.trunc(runningTime % 60))
        return "Time left: " + hour + min + ":" + sec
    }

    function send(name){
        var message = name ? name + " started" : "Time ran out"
        showMessage(window.title, message)
    }

    function popUp(){
        window.raise()
        window.show()
    }

    menu: Menu {

       MenuItem {
           text: updateTime()
           onTriggered: {window.active}
       }

        MenuSeparator {}

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
            text: qsTr("Settings")
            onTriggered: {
               if (stack.currentItem === content) {
                   popUp()
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
