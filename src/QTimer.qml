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

        pomodoroQueue.showQueue()
//        masterModel.showModel()

        pomodoroQueue.drainTime(1);

//        tray.runningTime = pomodoroQueue.infiniteMode ? splitDuration : duration

        const first = pomodoroQueue.first();

        if (first) {
            splitDuration = first.duration;

            const notificationsEnabled = pomodoroQueue.infiniteMode || appSettings.splitToSequence;

            if (notificationsEnabled)
                if (splitDuration === pomodoroQueue.itemDurationBound(first))
                    notifications.sendFromItem(first);

        } else
            splitDuration = 0;


        pixmap.requestPaint();
        canvas.requestPaint();
    }
}
