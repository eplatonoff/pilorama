import QtQuick 2.0
import Qt.labs.platform 1.1

SystemTrayIcon {
    id: tray
    visible: true
    icon.source: "./assets/tray/" + trayIconPath()
    property string appTitle: "QML Timer"
    property string messageText: ""
    property string menuItemText: checkMenuItemText()
    property string soundItemText: "Turn sound " + checkSoundItemText()

    property real dialTime: 0

    onDialTimeChanged: {trayIconPath()}

    onMessageClicked: window.visible
    onMessageTextChanged: showMessage(tray.appTitle, tray.messageText)

    function checkMenuItemText(){
        if (globalTimer.running && pomodoroQueue.infiniteMode) {
            return "Reset Pomodoro"
        } else if (globalTimer.running && !pomodoroQueue.infiniteMode){
            return "Reset Timer"
        } else {
            return "Start Pomodoro"
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
        var precision = 300
        var y = Math.abs(dialTime) + precision / 2;
        y = y - y % precision;
        return y / 60
    }

    function trayIconPath() {
      if(pomodoroQueue.infiniteMode){
          return pomodoroQueue.first().type + "-" + iconDialMin()
      } else if (!pomodoroQueue.infiniteMode && globalTimer.duration > 0){
          return "timer-" + iconDialMin()
      }
      else {
          return "static.svg"
      }
    }


    menu: Menu {
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
            text: qsTr("Settings")
            onTriggered: {
               if (content.currentItem === timerLayout) {content.push(prefsLayout)}
            }
        }
        MenuItem {
            text: tray.soundItemText
            onTriggered: {
                notifications.toggleSoundNotifications();
            }
        }
        MenuItem {
            text: qsTr("Quit")
            onTriggered: Qt.quit()
        }
    }


}
