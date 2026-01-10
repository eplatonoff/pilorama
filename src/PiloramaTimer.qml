import QtQuick

import Pilorama 1.0 as Pilorama

Pilorama.Timer {
    id: globalTimer

    property real remainingTime: 0 // ignored in the infinite mode
    property real segmentTotalDuration: 0
    property real segmentRemainingTime: 0
    property int _activeSegmentKey: -1

    property bool splitMode: pomodoroQueue.infiniteMode || preferences.splitToSequence

    property real timerLimit: 6 * 3600

    interval: 1000
    triggeredOnStart: true

    function stopAndClear() {
        stop();
        remainingTime = 0;
        segmentRemainingTime = 0;
        segmentTotalDuration = 0;
        _activeSegmentKey = -1;
        window.clockMode = "start";
        pomodoroQueue.clear();
        mouseArea._prevAngle = 0;
        mouseArea._totalRotatedSecs = 0;
        sequence.setCurrentItem(-1);
    }

    function segmentTotalForItem(item) {
        if (!item) {
            return 0;
        }
        if (item.total !== undefined) {
            return item.total;
        }
        return item.duration;
    }

    onRemainingTimeChanged: {
        window.checkClockMode();
        time.updateTime();
        canvas.requestPaint();

        if (!running && !splitMode) {
            segmentTotalDuration = remainingTime;
        }

        if (running && remainingTime <= 0) {
            notifications.sendWithSound()
            stopAndClear()
        }
    }
    onRunningChanged: {
        canvas.requestPaint();
        if (running) {
            if (splitMode) {
                const currentSegment = pomodoroQueue.first();
                if (currentSegment) {
                    _activeSegmentKey = currentSegment.key !== undefined ? currentSegment.key : currentSegment.id;
                    segmentTotalDuration = segmentTotalForItem(currentSegment);
                } else {
                    _activeSegmentKey = -1;
                    segmentTotalDuration = 0;
                }
            } else {
                segmentTotalDuration = remainingTime;
            }
        }
    }
    onSegmentTotalDurationChanged: {
        if (segmentRemainingTime <= 0)
            return;

        if (segmentRemainingTime === segmentTotalDuration) {
            notifications.sendFromItem(pomodoroQueue.first());
        }
    }
    onTriggered: elapsedSecs => {
        if (!pomodoroQueue.infiniteMode) {
            // subtract the main remaining time field even in the split mode
            remainingTime -= elapsedSecs;
        }

        if (splitMode) {
            const activeItem = pomodoroQueue.first();
            if (activeItem) {
                sequence.setCurrentItem(activeItem.id);
            } else {
                sequence.setCurrentItem();
            }
        } else {
            sequence.setCurrentItem();
        }

        pomodoroQueue.drainTime(elapsedSecs);

        const currentSegment = pomodoroQueue.first();

        if (currentSegment) {
            segmentRemainingTime = currentSegment.duration;

            if (splitMode) {
                const segmentKey = currentSegment.key !== undefined ? currentSegment.key : currentSegment.id;
                if (_activeSegmentKey !== segmentKey) {
                    _activeSegmentKey = segmentKey;
                    segmentTotalDuration = segmentTotalForItem(currentSegment);
                }
            }
        } else {
            segmentRemainingTime = 0;
            if (splitMode) {
                _activeSegmentKey = -1;
                segmentTotalDuration = 0;
            }
        }

        canvas.requestPaint();
    }
}
