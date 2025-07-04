import QtQuick

import Pilorama 1.0 as Pilorama

Pilorama.Timer {
    id: globalTimer

    property real remainingTime: 0 // ignored in the infinite mode
    property real segmentTotalDuration: 0
    property real segmentRemainingTime: 0

    property bool splitMode: pomodoroQueue.infiniteMode || preferences.splitToSequence

    property real timerLimit: 6 * 3600

    interval: 1000
    triggeredOnStart: true

    function stopAndClear() {
        stop();
        remainingTime = 0;
        window.clockMode = "start";
        pomodoroQueue.clear();
        mouseArea._prevAngle = 0;
        mouseArea._totalRotatedSecs = 0;
        sequence.setCurrentItem(-1);
    }

    onRemainingTimeChanged: {
        window.checkClockMode();
        time.updateTime();
        canvas.requestPaint();

        if (running && remainingTime <= 0) {
            notifications.sendWithSound()
            stopAndClear()
        }
    }
    onRunningChanged: {
        canvas.requestPaint();
        if (running) {
            segmentTotalDuration = splitMode ? pomodoroQueue.itemDurationBound() : remainingTime;
        }
    }
    onSegmentTotalDurationChanged: {
        if (segmentRemainingTime <= 0)
            return;

        if (segmentRemainingTime === pomodoroQueue.itemDurationBound()) {
            notifications.sendFromItem(pomodoroQueue.first());
        }
    }
    onTriggered: elapsedSecs => {
        if (!pomodoroQueue.infiniteMode) {
            // subtract the main remaining time field even in the split mode
            remainingTime -= elapsedSecs;
        }

        if (splitMode) {
            sequence.setCurrentItem(pomodoroQueue.first().id);
        } else {
            sequence.setCurrentItem();
        }

        pomodoroQueue.drainTime(elapsedSecs);

        const currentSegment = pomodoroQueue.first();

        if (currentSegment) {
            segmentRemainingTime = currentSegment.duration;

            if (splitMode) {
                segmentTotalDuration = pomodoroQueue.itemDurationBound();
            }
        } else {
            segmentRemainingTime = 0;
        }

        canvas.requestPaint();
    }
}
