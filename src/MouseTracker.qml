import QtQuick

import "utils/geometry.mjs" as GeometryScripts

MouseArea {

    anchors.fill: parent
    cursorShape: Qt.OpenHandCursor
    propagateComposedEvents: true
    visible: masterModel.count > 0


    signal rotated(real delta)

    property point circleStart: Qt.point(0, 0)
    property point mousePoint: Qt.point(0, 0)
    property real scroll: 0
    property real scrollMultiplier: 5

    property real _prevAngle: 0
    property real _totalRotated: 0
    property real _totalRotatedSecs: 0

    property real _totalRotatedSecsLimit: globalTimer.timerLimit

    // Indicates that the timer dial is actively dragged. Used by the
    // sequence view to preview the queue while the user adjusts the timer.
    property bool dragging: false

    onReleased: {
        cursorShape = Qt.OpenHandCursor
        if (globalTimer.remainingTime > 0) {
            globalTimer.start()

        }  else {
            globalTimer.stop();
            window.clockMode = "start"
            notifications.stopSound()
        }
        dragging = false
    }

    onRotated: (delta) => {
        const deltaSecs = delta * 10;

        this._totalRotated += delta;
        this._totalRotatedSecs += deltaSecs;

        if (_totalRotatedSecs >= 0 && _totalRotatedSecs <= _totalRotatedSecsLimit) {
            globalTimer.remainingTime = _totalRotatedSecs;
            durationSettings.timer = _totalRotatedSecs
            pomodoroQueue.changeQueue(deltaSecs);
        } else if (_totalRotatedSecs > _totalRotatedSecsLimit) {
             _totalRotatedSecs = _totalRotatedSecsLimit
        } else {
            _totalRotatedSecs = 0;
        }
    }

    onPressed: (mouse) => {
        focus = true

        cursorShape = Qt.ClosedHandCursor

        const angle = GeometryScripts.mouseAngle(
                        Qt.point(mouse.x, mouse.y),
                        Qt.point(canvas.centreX, canvas.centreY));

        // instantly rotate to the angle under the mouse in unitiated state
        if (this._totalRotatedSecs === 0) {
            this.rotated(angle < 0 ? (180 - angle) : angle);
        }

        this._prevAngle = angle;

        globalTimer.stop();
        pomodoroQueue.count > 1 ? pomodoroQueue.restoreDuration(0) : undefined
        pomodoroQueue.infiniteMode = false
        sequence.setCurrentItem(-1)
        dragging = true
    }

    onPositionChanged: (mouse) => {
        globalTimer.stop();

        const angle = GeometryScripts.mouseAngle(
                        Qt.point(mouse.x, mouse.y),
                        Qt.point(canvas.centreX, canvas.centreY));

        const delta = GeometryScripts.lessDelta(angle, this._prevAngle);

        this._prevAngle = angle;

        this.rotated(delta);
    }
}
