import QtQuick

import Pilorama 1.0 as Pilorama

Pilorama.Timer {
    id: globalTimer

    property var notificationsRef
    property var queueRef
    property var preferencesRef
    property var windowRef
    property var mouseAreaRef
    property var sequenceRef
    property var canvasRef
    property var timeRef
    property var macOSControllerRef

    property real remainingTime: 0 // ignored in the infinite mode
    property real segmentTotalDuration: 0
    property real segmentRemainingTime: 0
    property int _activeSegmentKey: -1
    property real durationBound: 0
    property real _lastTickMs: 0
    property real _currentTickNowMs: 0
    property bool _currentTickIsCatchUp: false
    property bool _pendingStartBoundarySchedule: false

    property bool splitMode: (globalTimer.queueRef ? globalTimer.queueRef.infiniteMode : false)
                             || (globalTimer.preferencesRef
                                 ? globalTimer.preferencesRef.splitToSequence : false)

    property real timerLimit: 6 * 3600

    interval: 1000
    triggeredOnStart: true

    function stopAndClear() {
        globalTimer.stop();
        globalTimer.remainingTime = 0;
        globalTimer.segmentRemainingTime = 0;
        globalTimer.segmentTotalDuration = 0;
        globalTimer._activeSegmentKey = -1;
        globalTimer.durationBound = 0;
        globalTimer._lastTickMs = 0;
        globalTimer._currentTickIsCatchUp = false;
        globalTimer._pendingStartBoundarySchedule = false;
        globalTimer.windowRef.clockMode = "start";
        globalTimer.queueRef.clear();
        globalTimer.mouseAreaRef._prevAngle = 0;
        globalTimer.mouseAreaRef._totalRotatedSecs = 0;
        globalTimer.sequenceRef.setCurrentItem(-1);
        globalTimer.notificationsRef.clearScheduled();
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

    function refreshSplitState() {
        if (globalTimer.splitMode) {
            const currentSegment = globalTimer.queueRef.first();
            if (currentSegment) {
                globalTimer._activeSegmentKey = globalTimer.segmentKeyForItem(currentSegment);
                globalTimer.segmentRemainingTime = currentSegment.duration;
                globalTimer.segmentTotalDuration = globalTimer.segmentTotalForItem(currentSegment);
            } else {
                globalTimer._activeSegmentKey = -1;
                globalTimer.segmentRemainingTime = 0;
                globalTimer.segmentTotalDuration = 0;
            }
        } else {
            globalTimer._activeSegmentKey = -1;
            globalTimer.segmentRemainingTime = globalTimer.remainingTime;
            globalTimer.segmentTotalDuration = globalTimer.remainingTime;
        }
    }

    function handleLiveSplitPreferenceChange() {
        if (!globalTimer.running)
            return;
        globalTimer.refreshSplitState();
        globalTimer.notificationsRef.scheduleNextSegment();
        globalTimer.canvasRef.requestPaint();
    }

    property Connections splitPreferenceConnections: Connections {
        target: globalTimer.preferencesRef

        function onSplitToSequenceChanged() {
            globalTimer.handleLiveSplitPreferenceChange()
        }
    }

    onRemainingTimeChanged: {
        globalTimer.windowRef.checkClockMode();
        globalTimer.timeRef.updateTime();
        globalTimer.canvasRef.requestPaint();

        if (!globalTimer.running && !globalTimer.splitMode) {
            globalTimer.segmentTotalDuration = globalTimer.remainingTime;
        }

        if (globalTimer.running && globalTimer.remainingTime <= 0) {
            if (!globalTimer.notificationsRef.shouldSuppressCatchUpCompletion(
                        globalTimer._currentTickNowMs,
                        globalTimer._currentTickIsCatchUp)) {
                globalTimer.notificationsRef.sendWithSound();
            }
            stopAndClear();
        }
    }
    onRunningChanged: {
        globalTimer.canvasRef.requestPaint();
        if (globalTimer.running) {
            globalTimer.macOSControllerRef.beginAppNapActivity();
            globalTimer._lastTickMs = Date.now();
            globalTimer.durationBound = globalTimer.remainingTime;
            globalTimer.refreshSplitState();
            globalTimer._pendingStartBoundarySchedule = globalTimer.triggeredOnStart;
            if (!globalTimer._pendingStartBoundarySchedule) {
                globalTimer.notificationsRef.scheduleNextSegment();
            }
        } else {
            globalTimer.macOSControllerRef.endAppNapActivity();
            globalTimer._lastTickMs = 0;
            globalTimer._currentTickIsCatchUp = false;
            globalTimer._pendingStartBoundarySchedule = false;
            globalTimer.notificationsRef.clearScheduled();
        }
    }
    onTriggered: elapsedSecs => {
        const nowMs = Date.now();
        globalTimer._currentTickNowMs = nowMs;
        let didScheduleBoundary = false;
        let actualElapsed = elapsedSecs;
        const intervalSecs = globalTimer.interval / 1000.0;
        let wallClockGapLooksLikeCatchUp = false;
        if (globalTimer._lastTickMs > 0) {
            const wallClockElapsed = (nowMs - globalTimer._lastTickMs) / 1000.0;
            wallClockGapLooksLikeCatchUp = wallClockElapsed > intervalSecs + 0.25;
            if (elapsedSecs > intervalSecs || wallClockGapLooksLikeCatchUp)
                actualElapsed = Math.max(actualElapsed, wallClockElapsed);
        }
        globalTimer._lastTickMs = nowMs;
        if (actualElapsed < 0)
            actualElapsed = 0;
        globalTimer._currentTickIsCatchUp = elapsedSecs > intervalSecs
                                            || wallClockGapLooksLikeCatchUp;
        if (actualElapsed === 0) {
            globalTimer.canvasRef.requestPaint();
            globalTimer._currentTickIsCatchUp = false;
            globalTimer._currentTickNowMs = 0;
            return;
        }

        if (!globalTimer.queueRef.infiniteMode) {
            // Keep remainingTime authoritative for finite timers, including split mode.
            // In infinite mode, remainingTime is ignored.
            globalTimer.remainingTime -= actualElapsed;
        }

        if (globalTimer.splitMode) {
            const activeItem = globalTimer.queueRef.first();
            if (activeItem) {
                globalTimer.sequenceRef.setCurrentItem(activeItem.id);
            } else {
                globalTimer.sequenceRef.setCurrentItem();
            }
        } else {
            globalTimer.sequenceRef.setCurrentItem();
        }

        globalTimer.queueRef.drainTime(actualElapsed);

        const currentSegment = globalTimer.queueRef.first();

        if (currentSegment) {
            const segmentKey = segmentKeyForItem(currentSegment);
            const segmentChanged = globalTimer.splitMode
                                   && globalTimer._activeSegmentKey !== segmentKey;
            globalTimer.segmentRemainingTime = currentSegment.duration;

            if (globalTimer.splitMode) {
                if (segmentChanged) {
                    globalTimer._activeSegmentKey = segmentKey;
                    globalTimer.segmentTotalDuration = segmentTotalForItem(currentSegment);
                    if (!globalTimer.notificationsRef.shouldSuppressCatchUpSegment(
                                currentSegment,
                                nowMs,
                                globalTimer._currentTickIsCatchUp)) {
                        globalTimer.notificationsRef.sendFromItem(currentSegment);
                    } else {
                        globalTimer.notificationsRef.popUpForSegmentStart();
                    }
                    globalTimer.notificationsRef.scheduleNextSegment();
                    didScheduleBoundary = true;
                }
            }
        } else {
            globalTimer.segmentRemainingTime = 0;
            if (globalTimer.splitMode) {
                globalTimer._activeSegmentKey = -1;
                globalTimer.segmentTotalDuration = 0;
            }
        }

        if (globalTimer._pendingStartBoundarySchedule) {
            globalTimer._pendingStartBoundarySchedule = false;
            if (globalTimer.running && !didScheduleBoundary) {
                globalTimer.notificationsRef.scheduleNextSegment();
            }
        }

        globalTimer.canvasRef.requestPaint();
        globalTimer._currentTickIsCatchUp = false;
        globalTimer._currentTickNowMs = 0;
    }
}
