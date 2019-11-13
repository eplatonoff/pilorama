import QtQuick 2.0

Timer {

    property real duration: 0
    property real splitDuration: 0

    property int secsInterval: Math.trunc(interval / 1000)

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
                stop();

                pomodoroQueue.clear();
                mouseArea._prevAngle = 0
                mouseArea._totalRotatedSecs = 0

            }
        }

        const firstItem = pomodoroQueue.first();

        if (firstItem) {
            splitDuration = firstItem.duration;

            if (splitDuration === pomodoroQueue.itemDurationBound(firstItem)) {
                notifications.sendFromItem(firstItem);
            }

        } else {
            splitDuration = 0;
        }

        pomodoroQueue.drainTime(secsInterval);

        time.updateTime();

        canvas.requestPaint();
    }
}
