import QtQuick

import Pilorama 1.0 as Pilorama

Pilorama.Timer {
    id: globalTimer

    property real remainingTime: 0 // ignored in the infinite mode
    property real segmentTotalDuration: 0
    property real segmentRemainingTime: 0
    property int _activeSegmentKey: -1
    property real durationBound: 0
    property real _lastTickMs: 0

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
        durationBound = 0;
        _lastTickMs = 0;
        window.clockMode = "start";
        pomodoroQueue.clear();
        mouseArea._prevAngle = 0;
        mouseArea._totalRotatedSecs = 0;
        sequence.setCurrentItem(-1);
        notifications.clearScheduled();
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

    function segmentKeyForItem(item) {
        if (!item)
            return -1;
        return item.key !== undefined ? item.key : item.id;
    }

    onRemainingTimeChanged: {
        window.checkClockMode();
        time.updateTime();
        canvas.requestPaint();

        if (!running && !splitMode) {
            segmentTotalDuration = remainingTime;
        }

        if (running && remainingTime <= 0) {
            notifications.sendWithSound();
            stopAndClear();
        }
    }
    onRunningChanged: {
        canvas.requestPaint();
        if (running) {
            MacOSController.beginAppNapActivity();
            _lastTickMs = Date.now();
            durationBound = remainingTime;
            if (splitMode) {
                const currentSegment = pomodoroQueue.first();
                if (currentSegment) {
                    _activeSegmentKey = segmentKeyForItem(currentSegment);
                    segmentRemainingTime = currentSegment.duration;
                    segmentTotalDuration = segmentTotalForItem(currentSegment);
                } else {
                    _activeSegmentKey = -1;
                    segmentRemainingTime = 0;
                    segmentTotalDuration = 0;
                }
            } else {
                segmentRemainingTime = remainingTime;
                segmentTotalDuration = remainingTime;
            }
            notifications.scheduleNextSegment();
        } else {
            MacOSController.endAppNapActivity();
            _lastTickMs = 0;
            notifications.clearScheduled();
        }
    }
    onTriggered: elapsedSecs => {
        const nowMs = Date.now();
        let actualElapsed = elapsedSecs;
        if (_lastTickMs > 0) {
            actualElapsed = (nowMs - _lastTickMs) / 1000.0;
        }
        _lastTickMs = nowMs;
        if (actualElapsed < 0)
            actualElapsed = 0;
        if (actualElapsed > timerLimit)
            actualElapsed = timerLimit;
        if (actualElapsed === 0) {
            canvas.requestPaint();
            return;
        }

        if (!pomodoroQueue.infiniteMode) {
            // Keep remainingTime authoritative for finite timers, including split mode.
            // In infinite mode, remainingTime is ignored.
            remainingTime -= actualElapsed;
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

        pomodoroQueue.drainTime(actualElapsed);

        const currentSegment = pomodoroQueue.first();

        if (currentSegment) {
            const segmentKey = segmentKeyForItem(currentSegment);
            const segmentChanged = splitMode && _activeSegmentKey !== segmentKey;
            segmentRemainingTime = currentSegment.duration;

            if (splitMode) {
                if (segmentChanged) {
                    _activeSegmentKey = segmentKey;
                    segmentTotalDuration = segmentTotalForItem(currentSegment);
                    notifications.sendFromItem(currentSegment);
                    notifications.scheduleNextSegment();
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
