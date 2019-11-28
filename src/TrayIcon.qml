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

    onMessageClicked: window.visible
    onMessageTextChanged: showMessage(tray.appTitle, tray.messageText)


    function checkMenuItemText(){
        if (globalTimer.running && pomodoroQueue.infiniteMode) {
            return "Reset Timer"
        } else {
            return "Start Sequence"
        }
    }

    function checkSoundItemText(){
        if (notifications.soundMuted) {
            return "on"
        } else {
            return "off"
        }
    }

    function iconDialMin(){
        var precision = 120
        var y = Math.abs(dialTime) + precision / 2;
        y = y - y % precision;
        return y / 60
    }

    function iconURL() {
      const path = './assets/tray/'
      if(globalTimer.running){
          return path +  "timer-" + iconDialMin()
      }
      else {
          return path + "static.svg"
      }
    }

    function setDialTime(){
        const t = pomodoroQueue.first().duration * 3600 / masterModel.get(pomodoroQueue.first().id).duration
        dialTime = pomodoroQueue.first() ? t : 0
        iconURL()
    }

    function setTime(){
        runningTime = pomodoroQueue.infiniteMode ? globalTimer.splitDuration : globalTimer.duration
        setDialTime()
        updateTime()
    }

    function pad(value){
        if (value < 10) {return "0" + value
        } else {return value}
    }

    function updateTime(){
        let h = Math.trunc(runningTime / 3600)
        let hour = h > 0 ? h + ":" : ""
        let min = pad(Math.trunc(runningTime / 60) - Math.trunc(runningTime / 3600) * 60)
        let sec = pad(Math.trunc(runningTime % 60))
        return "Time left: " + hour + min + ":" + sec
    }

    function send(name){
        var message = name ? name + " started" : "Time ran out"
        showMessage(window.title, message )
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

                    pomodoroQueue.infiniteMode = false
                    pomodoroQueue.clear();

                    mouseArea._prevAngle = 0
                    mouseArea._totalRotatedSecs = 0

                    globalTimer.duration = 0
                    globalTimer.stop()

                    window.clockMode = "start"

                    notifications.stopSound();
                } else {
                    window.clockMode = "pomodoro"
                    pomodoroQueue.infiniteMode = true
                    globalTimer.start()
                    tray.messageText = "Pomodoro started. Click to show timer"

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
               if (stack.currentItem === content) {stack.push(preferences)}
            }
        }

        MenuSeparator {}

        MenuItem {
            text: qsTr("Quit")
            onTriggered: Qt.quit()
        }
    }
}
