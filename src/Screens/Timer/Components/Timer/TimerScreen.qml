import QtQuick

import "../../../../Components"

Item {
    id: timer

    function count(duration) {
        let d = duration;
        let h = Math.floor(d / 3600);
        let m = Math.floor(d / 60) - h * 60;
        let s = d - (h * 3600 + m * 60);
        const t = [h, m, s];
        return t;
    }
    function getDuration() {
        if (!burnerModel.infiniteMode) {
            return piloramaTimer.duration;
        } else {
            return piloramaTimer.splitDuration;
        }
    }
    function pad(value) {
        if (value < 10) {
            return "0" + value;
        } else {
            return value;
        }
    }

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    height: 150
    visible: window.clockMode === "pomodoro" || window.clockMode === "timer"
    width: 150

    MouseArea {
        id: triggerBlocker

        anchors.fill: parent
        propagateComposedEvents: true
    }
    Item {
        id: dateTime

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 23
        height: 15
        width: 70

        Icon {
            id: bellIcon

            anchors.left: parent.left
            anchors.verticalCenter: digitalTime.verticalCenter
            glyph: "\uea02"
            size: 18
        }
        Text {
            id: digitalTime

            anchors.left: bellIcon.right
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor("mid")
            font.family: localFont.name
            font.pixelSize: 14
            height: 15
            horizontalAlignment: Text.AlignLeft
            renderType: Text.NativeRendering
            text: clock.notificationTime
            verticalAlignment: Text.AlignVCenter
            width: 45
        }
    }
    Item {
        id: digital

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 0
        anchors.top: dateTime.bottom
        anchors.topMargin: 6
        height: 50
        width: digitalHour.width + digitalSeparator.width + digitalMin.width + 5 + digitalSec.width

        Text {
            id: digitalSec

            anchors.left: digitalMin.right
            anchors.leftMargin: 5
            anchors.top: digitalMin.top
            anchors.topMargin: 6
            color: colors.getColor("dark")
            font.pixelSize: 22
            horizontalAlignment: Text.AlignLeft
            renderType: Text.NativeRendering
            text: !piloramaTimer.running ? "min" : pad(count(getDuration())[2])
            verticalAlignment: Text.AlignTop
            width: 36
        }
        Text {
            id: digitalMin

            anchors.left: digitalSeparator.right
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor("dark")
            font.pixelSize: 44
            horizontalAlignment: Text.AlignHCenter
            renderType: Text.NativeRendering
            text: pad(count(getDuration())[1])
            verticalAlignment: Text.AlignTop
            width: 50
        }
        Text {
            id: digitalSeparator

            anchors.left: digitalHour.right
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor("dark")
            font.pixelSize: 44
            horizontalAlignment: Text.AlignHCenter
            renderType: Text.NativeRendering
            text: qsTr(":")
            verticalAlignment: Text.AlignTop
            visible: digitalHour.visible
            width: 14
        }
        Text {
            id: digitalHour

            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor("dark")
            font.pixelSize: 44
            horizontalAlignment: Text.AlignRight
            renderType: Text.NativeRendering
            text: count(getDuration())[0]
            verticalAlignment: Text.AlignTop
            visible: count(getDuration())[0] > 0 ? true : false
            width: count(getDuration())[0] > 0 ? 35 : 0
        }
    }
    ResetButton {
        id: resetButton

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        label: 'Reset'

        MouseArea {
            id: digitalClockResetTrigger

            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            propagateComposedEvents: true

            onReleased: {
                burnerModel.infiniteMode = false;
                burnerModel.clear();
                mouseTrackerArea._prevAngle = 0;
                mouseTrackerArea._totalRotatedSecs = 0;
                piloramaTimer.duration = 0;
                piloramaTimer.stop();
                window.clockMode = "start";
                sequence.setCurrentItem(-1);
                focus = true;
            }
        }
    }
}
