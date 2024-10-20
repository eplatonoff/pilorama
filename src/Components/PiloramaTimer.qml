import QtQuick

import Pilorama 1.0 as Pilorama

Pilorama.Timer {
    property var burnerModel
    property var canvas
    property real duration: 660
    property real durationBound: 0
    property var mouseTrackerArea
    property var sequence
    property real splitDuration: 0
    property real timerLimit: 6 * 3600

    interval: 1000
    triggeredOnStart: true

    onDurationChanged: {
        window.checkClockMode();
        time.updateTime();
        canvas.requestPaint();
    }
    onRunningChanged: {
        canvas.requestPaint();
        if (running) {
            durationBound = duration;
        }
    }
    onTriggered: elapsedSecs => {
        if (duration >= 1) {
            duration -= elapsedSecs;
        } else {
            notifications.send();
            window.clockMode = "start";
            burnerModel.clear();
            mouseTrackerArea._prevAngle = 0;
            mouseTrackerArea._totalRotatedSecs = 0;
            sequence.setCurrentItem(-1);
            stop();
        }
        sequence.setCurrentItem(burnerModel.first().id);
        burnerModel.drainTime(elapsedSecs);
        const first = burnerModel.first();
        if (first) {
            splitDuration = first.duration;
            if (splitDuration === burnerModel.itemDurationBound(first))
                notifications.sendFromItem(first);
        } else {
            splitDuration = 0;
        }
        tray.setTime();
        canvas.requestPaint();
    }
}
