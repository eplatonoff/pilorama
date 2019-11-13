import QtQuick 2.0

Timer {

    property real duration: 0
    property real splitDuration: 0

    onDurationChanged: {
        window.checkClockMode();
        time.updateTime();
        canvas.requestPaint();
    }

    interval: 1000
    running: false
    repeat: true

    onTriggered: {

        if (!pomodoroQueue.infiniteMode) {
            if (duration >= 1){
                duration--;
            } else {
                notifications.sendWithSound(NotificationSystem.STOP);
                window.clockMode = "start";
                pomodoroQueue.clear();
                mouseArea._prevAngle = 0
                mouseArea._totalRotatedSecs = 0
                stop();
            }
        }

        pomodoroQueue.drainTime(1);

        const firstItem = pomodoroQueue.first();
        firstItem ? splitDuration = firstItem.duration : splitDuration = 0

        if(splitDuration === pomodoroQueue.itemDurationBound(firstItem)){
            if (pomodoroQueue.infiniteMode || appSettings.splitToSequence){
                notifications.sendFromItem(firstItem);
            }
        }

        canvas.requestPaint();
    }
}
