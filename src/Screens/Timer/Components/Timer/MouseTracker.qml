import QtQuick

import "../../../../utils/geometry.mjs" as GeometryScripts

MouseArea {
    property real _prevAngle: 0
    property real _totalRotated: 0
    property real _totalRotatedSecs: 0
    property real _totalRotatedSecsLimit: piloramaTimer.timerLimit
    property point circleStart: Qt.point(0, 0)
    property point mousePoint: Qt.point(0, 0)
    property real scroll: 0
    property real scrollMultiplier: 5

    signal rotated(real delta)

    anchors.fill: parent
    cursorShape: Qt.OpenHandCursor
    propagateComposedEvents: true
    visible: timerModel.count > 0

    onPositionChanged: mouse => {
        piloramaTimer.stop();
        const angle = GeometryScripts.mouseAngle(Qt.point(mouse.x, mouse.y), Qt.point(canvas.centreX, canvas.centreY));
        const delta = GeometryScripts.lessDelta(angle, this._prevAngle);
        this._prevAngle = angle;
        this.rotated(delta);
    }
    onPressed: mouse => {
        focus = true;
        cursorShape = Qt.ClosedHandCursor;
        const angle = GeometryScripts.mouseAngle(Qt.point(mouse.x, mouse.y), Qt.point(canvas.centreX, canvas.centreY));

        // instantly rotate to the angle under the mouse in unitiated state
        if (this._totalRotatedSecs === 0) {
            this.rotated(angle < 0 ? (180 - angle) : angle);
        }
        this._prevAngle = angle;
        piloramaTimer.stop();
        burnerModel.count > 1 ? burnerModel.restoreDuration(0) : undefined;
        sequence.setCurrentItem(-1);
    }
    onReleased: {
        cursorShape = Qt.OpenHandCursor;
        if (piloramaTimer.duration > 0) {
            piloramaTimer.start();
        } else {
            piloramaTimer.stop();
            window.clockMode = "start";
            notifications.stopSound();
        }
    }
    onRotated: delta => {
        const deltaSecs = delta * 10;
        this._totalRotated += delta;
        this._totalRotatedSecs += deltaSecs;
        if (_totalRotatedSecs >= 0 && _totalRotatedSecs <= _totalRotatedSecsLimit) {
            piloramaTimer.duration = _totalRotatedSecs;
            durationSettings.timer = _totalRotatedSecs;
            burnerModel.changeQueue(deltaSecs);
        } else if (_totalRotatedSecs > _totalRotatedSecsLimit) {
            _totalRotatedSecs = _totalRotatedSecsLimit;
        } else {
            _totalRotatedSecs = 0;
        }
    }
}
