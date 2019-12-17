import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: timer
    visible: window.clockMode === "pomodoro" || window.clockMode === "timer"
    width: 150
    height: 150
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    function pad(value){
        if (value < 10) {return "0" + value
        } else {return value}
    }

    function getDuration(){
        if(!pomodoroQueue.infiniteMode){
          return globalTimer.duration
        } else {
          return globalTimer.splitDuration
        }
    }

    function count(duration){
        let d = duration

        let h = Math.floor( d / 3600 )
        let m = Math.floor( d / 60 ) - h * 60
        let s = d - (h * 3600 + m * 60)

        const t = [ h, m, s ]
        return t
    }

    MouseArea {
        id: triggerBlocker
        anchors.fill: parent
        propagateComposedEvents: true
    }

    Item {
        id: dateTime
        width: 70
        height: 15
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 23

        Image {
            id: bellIcon
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: digitalTime.verticalCenter
            sourceSize.height: 16
            sourceSize.width: 16
            source: "../assets/img/bell.svg"
            antialiasing: true
            fillMode: Image.PreserveAspectFit

            ColorOverlay{
                id: bellIconOverlay
                anchors.fill: parent
                source: parent
                color: appSettings.darkMode ? colors.accentDark : colors.accentLight
                antialiasing: true
            }
        }

        Text {
            id: digitalTime
            width: 45
            height: 15
            text: clock.notificationTime
            anchors.left: bellIcon.right
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter

            font.family: localFont.name
            font.pixelSize: 14

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            color: colors.getColor("mid")

            renderType: Text.NativeRendering
        }
    }


    Item{
        id: digital
        height: 50
        anchors.horizontalCenterOffset: 0
        width: digitalHour.width + digitalSeparator.width + digitalMin.width + 5 + digitalSec.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: dateTime.bottom
        anchors.topMargin: 6

        Text {
            id: digitalSec
            width: 36
            text: !globalTimer.running ? "min" : pad(count(getDuration())[2]);
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            anchors.top: digitalMin.top
            anchors.topMargin: 6
            anchors.left: digitalMin.right
            anchors.leftMargin: 5
            font.pixelSize: 22
            color: colors.getColor("dark")

            renderType: Text.NativeRendering

        }

        Text {
            id: digitalMin
            width: 50
            text: pad(count(getDuration())[1])
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            anchors.left: digitalSeparator.right
            anchors.leftMargin: 0
            font.pixelSize: 44
            color: colors.getColor("dark")

            renderType: Text.NativeRendering


        }

        Text {
            id: digitalSeparator
            width: 14
            text: qsTr(":")
            anchors.left: digitalHour.right
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            visible: digitalHour.visible
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            font.pixelSize: 44
            color: colors.getColor("dark")

            renderType: Text.NativeRendering


        }

        Text {
            id: digitalHour
            width: count(getDuration())[0] > 0 ? 35 : 0
            text: count(getDuration())[0]
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            visible: count(getDuration())[0] > 0 ? true : false
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignTop
            font.pixelSize: 44
            color: colors.getColor("dark")

            renderType: Text.NativeRendering


        }
    }

    ResetButton {
        id: resetButton
        label: 'Reset'
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter

        MouseArea {
            id: digitalClockResetTrigger
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor

            onReleased: {
                pomodoroQueue.infiniteMode = false;
                pomodoroQueue.clear();
                mouseArea._prevAngle = 0
                mouseArea._totalRotatedSecs = 0
                globalTimer.duration = 0
                globalTimer.stop()
                window.clockMode = "start"
                notifications.stopSound();
                sequence.setCurrentItem(-1)

                focus = true
            }
        }
    }

}
