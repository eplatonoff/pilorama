import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
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

    Image {
        id: bellIcon
        anchors.left: parent.left
        anchors.leftMargin: 37
        anchors.top: parent.top
        anchors.topMargin: 25
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
        width: 80
        height: 15
        text: showFuture()
        font.bold: true
        font.pixelSize: 14
        verticalAlignment: Text.AlignVCenter
        anchors.verticalCenter: bellIcon.verticalCenter
        anchors.left: bellIcon.right
        anchors.leftMargin: 1
        anchors.bottom: digitalMin.top
        anchors.bottomMargin: 5
        horizontalAlignment: Text.AlignLeft
        color: appSettings.darkMode ? colors.accentDark : colors.accentLight

        function showFuture() {
            var extraTime;
            if (!pomodoroQueue.infiniteMode){
                extraTime = globalTimer.duration
            } else {
                switch (pomodoroQueue.first().type) {
                case "pomodoro":
                    extraTime = durationSettings.pomodoro
                    break;
                case "pause":
                    extraTime =  durationSettings.pause;
                    break;
                case "break":
                    extraTime = durationSettings.breakTime;
                    break;
                default:
                    throw "can't calculate notification time";
                }

            }
            var future = time.hours * 3600 + time.minutes *60 + time.seconds + extraTime
            var h = Math.trunc(future / 3600)
            var m = Math.trunc((future - h * 3600) / 60)
            return parent.pad(h) + ":" + parent.pad(m)
        }

    }

    Text {
        id: digitalSec
        width: 51
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
                return parent.pad(Math.trunc(globalTimer.splitDuration % 60))
            } else if(!pomodoroQueue.infiniteMode && !globalTimer.running) {
                return "min"
            }else {
                return parent.pad(Math.trunc(globalTimer.duration % 60))
            }
        }
    }

    Text {
        id: digitalMin
        width: 60
        text: minutes()
        anchors.top: parent.top
        anchors.topMargin: 38
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignTop
        anchors.left: parent.left
        anchors.leftMargin: 26
        font.pixelSize: 44
        color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight

        function minutes(){
            if (pomodoroQueue.infiniteMode){
                return parent.pad(Math.trunc(globalTimer.splitDuration / 60))
            } else {
                return parent.pad(Math.trunc(globalTimer.duration / 60))
            }
        }
    }



    FocusScope {
        id: splitToPomo
        height: 25
        anchors.bottom: resetButton.top
        anchors.bottomMargin: 3
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0

    }

    ResetButton {
        id: resetButton
        y: 112
        height: 38
        anchors.bottomMargin: 12
    }

}
