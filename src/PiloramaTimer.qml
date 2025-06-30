import QtQuick

import Pilorama 1.0 as Pilorama

Pilorama.Timer {

    triggeredOnStart: true

    property real duration: 0
    property real durationBound: 0
    property real splitDuration: 0

    property real timerLimit: 6 * 3600
    // number of seconds between tray icon updates
    property int trayUpdateInterval: 5
    property int trayUpdateCounter: 0

    onDurationChanged: {
        window.checkClockMode();
        time.updateTime();
        canvas.requestPaint();
    }

    interval: 1000

    onRunningChanged: {
        canvas.requestPaint();
        if ( running ) {
            durationBound = duration;
            tray.runningTime = pomodoroQueue.infiniteMode ? splitDuration : duration
            tray.setDialTime()
            trayUpdateCounter = 0
        }
    }

    onTriggered: (elapsedSecs) => {
        if (!pomodoroQueue.infiniteMode) {
            if (duration >= 1){
                duration -= elapsedSecs;

            } else {
                notifications.sendWithSound();
                window.clockMode = "start";
                pomodoroQueue.clear();
                mouseArea._prevAngle = 0
                mouseArea._totalRotatedSecs = 0
                sequence.setCurrentItem(-1)
                stop();
            }
        }

        if(pomodoroQueue.infiniteMode || preferences.splitToSequence) {
            sequence.setCurrentItem(pomodoroQueue.first().id)
        } else { sequence.setCurrentItem() }

        pomodoroQueue.drainTime(elapsedSecs);

        const first = pomodoroQueue.first();

        if (first) {
            splitDuration = first.duration;

            const notificationsEnabled = pomodoroQueue.infiniteMode || preferences.splitToSequence;

            if (notificationsEnabled)
                if (splitDuration === pomodoroQueue.itemDurationBound(first)) {
                    notifications.sendFromItem(first);
                }

        } else
            splitDuration = 0;

        tray.runningTime = pomodoroQueue.infiniteMode ? splitDuration : duration
        trayUpdateCounter += elapsedSecs

        if (trayUpdateCounter >= trayUpdateInterval || tray.runningTime <= 0) {
            tray.setDialTime()
            trayUpdateCounter = 0
        }

        canvas.requestPaint();
    }
}
