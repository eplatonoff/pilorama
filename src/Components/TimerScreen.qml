import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: timer
    visible: window.clockMode === "pomodoro" || window.clockMode === "timer"
    width: 150
    height: 150
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    property string min: "00"
    property string sec: "00"

    function pad(value){
        if (value < 10) {return "0" + value
        } else {return value}
    }
    Item {
        id: dateTime
        width: 60
        height: 15
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20

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
            text: showFuture()
            anchors.left: bellIcon.right
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            color: appSettings.darkMode ? colors.accentDark : colors.accentLight

            function showFuture() {
                var extraTime;
                if (!pomodoroQueue.infiniteMode){
                    extraTime = globalTimer.duration
                } else {
                    extraTime = masterModel.get(pomodoroQueue.first().id).duration

                }
                var future = time.hours * 3600 + time.minutes *60 + time.seconds + extraTime
                var h = Math.trunc(future / 3600)
                var m = Math.trunc((future - h * 3600) / 60)
                return timer.pad(h) + ":" + timer.pad(m)
            }

        }
    }


    Item{
        id: digital
        height: 50
        width: digitalHour.width + digitalSeparator.width + digitalMin.width + 3 + digitalSec.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 39

        Text {
            id: digitalSec
            width: 36
            text: seconds();
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            anchors.top: digitalMin.top
            anchors.topMargin: 6
            anchors.left: digitalMin.right
            anchors.leftMargin: 3
            font.pixelSize: 22
            color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight

            function seconds(){
                if (pomodoroQueue.infiniteMode === true){
                    return timer.pad(Math.trunc(globalTimer.splitDuration % 60))
                } else if(!pomodoroQueue.infiniteMode && !globalTimer.running) {
                    return "min"
                }else {
                    return timer.pad(Math.trunc(globalTimer.duration % 60))
                }
            }
        }

        Text {
            id: digitalMin
            width: 50
            text: minutes()
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            anchors.left: digitalSeparator.right
            anchors.leftMargin: 0
            font.pixelSize: 44
            color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight

            function minutes(){
                if (pomodoroQueue.infiniteMode){
                    return timer.pad(Math.trunc(globalTimer.splitDuration / 60) - Math.trunc(globalTimer.duration / 3600) * 60)
                } else {
                    return timer.pad(Math.trunc(globalTimer.duration / 60) - Math.trunc(globalTimer.duration / 3600) * 60)
                }
            }
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
            color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight

        }

        Text {
            id: digitalHour
            width: 0
            text: hours()
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            visible: false
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignTop
            font.pixelSize: 44
            color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight

            function hours(){
                var h
                if (pomodoroQueue.infiniteMode){
                   h = Math.trunc(globalTimer.splitDuration / 3600)
                } else {
                   h = Math.trunc(globalTimer.duration / 3600)
                }

                visible = h > 0 ? true : false
                width = h > 0 ? 35 : 0

                return h
            }
        }
    }

    ResetButton {
        id: resetButton
        y: 112
        height: 38
        anchors.bottomMargin: 16
    }

}
