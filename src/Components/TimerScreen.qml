import QtQuick

Item {
    id: timer
    visible: windowRef.clockMode === "pomodoro" || windowRef.clockMode === "timer"
    width: 150
    height: 150
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    property var windowRef
    property var timerRef
    property var clockRef
    property var colorsRef
    property var fontRef
    property var queueRef
    property var notificationsRef
    property var settingsRef

    function pad(value){
        if (value < 10) {return "0" + value
        } else {return value}
    }

    function getDuration(){
        if (timerRef.splitMode) {
            if (timerRef.running && timerRef.segmentRemainingTime > 0) {
                return timerRef.segmentRemainingTime
            }
            return timerRef.remainingTime
        }
        return timerRef.remainingTime
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

        Icon {
            id: bellIcon
            glyph: "\uea02"
            size: 18
            anchors.left: parent.left
            anchors.verticalCenter: digitalTime.verticalCenter
        }

        // Image {
        //     id: bellIcon
        //     anchors.left: parent.left
        //     anchors.leftMargin: 0
        //     anchors.verticalCenter: digitalTime.verticalCenter
        //     sourceSize.height: 16
        //     sourceSize.width: 16
        //     source: "../assets/img/bell.svg"
        //     antialiasing: true
        //     fillMode: Image.PreserveAspectFit

        //     ColorOverlay{
        //         id: bellIconOverlay
        //         anchors.fill: parent
        //         source: parent
        //         color: appSettings.darkMode ? colors.accentDark : colors.accentLight
        //         antialiasing: true
        //     }
        // }

        Text {
            id: digitalTime
            width: 45
            height: 15
            text: timer.clockRef.notificationTime
            anchors.left: bellIcon.right
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter

            font.family: timer.fontRef.name
            font.pixelSize: 14

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            color: timer.colorsRef.getColor("mid")

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
            text: timer.timerRef.running || timer.getDuration() > 0
                  ? timer.pad(timer.count(timer.getDuration())[2])
                  : "min";
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            anchors.top: digitalMin.top
            anchors.topMargin: 6
            anchors.left: digitalMin.right
            anchors.leftMargin: 5
            font.pixelSize: 22
            color: timer.colorsRef.getColor("dark")

            renderType: Text.NativeRendering

        }

        Text {
            id: digitalMin
            width: 50
            text: timer.pad(timer.count(timer.getDuration())[1])
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            anchors.left: digitalSeparator.right
            anchors.leftMargin: 0
            font.pixelSize: 44
            color: timer.colorsRef.getColor("dark")

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
            color: timer.colorsRef.getColor("dark")

            renderType: Text.NativeRendering


        }

        Text {
            id: digitalHour
            width: timer.count(timer.getDuration())[0] > 0 ? 35 : 0
            text: timer.count(timer.getDuration())[0]
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            visible: timer.count(timer.getDuration())[0] > 0
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignTop
            font.pixelSize: 44
            color: timer.colorsRef.getColor("dark")

            renderType: Text.NativeRendering


        }
    }

    TimerControls {
        id: controls
        label: 'Reset'
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        splitMode: timer.settingsRef.showPauseUI
        iconSize: 22
        running: timer.timerRef.running
        togglePulsing: !timer.timerRef.running

        onStartResetClicked: {
           reset();
        }

        onToggleClicked: {
            if (timer.timerRef.running) {
                timer.timerRef.stop()
            } else {
                timer.timerRef.triggeredOnStart = false
                timer.timerRef.start()
                timer.timerRef.triggeredOnStart = true
            }
        }

        function reset() {
            timer.queueRef.infiniteMode = false;
            timer.timerRef.stopAndClear()
            timer.notificationsRef.stopSound();
        }

    }

}
