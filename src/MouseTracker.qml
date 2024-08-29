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

    onReleased: {
        cursorShape = Qt.OpenHandCursor
        if (globalTimer.duration > 0) {
            globalTimer.start()

        }  else {
            globalTimer.stop();
            window.clockMode = "start"
            notifications.stopSound()
        }
    }

    onRotated: (delta) => {

        const deltaSecs = delta * 10;

        this._totalRotated += delta;
        this._totalRotatedSecs += deltaSecs;

        if (_totalRotatedSecs >= 0 && _totalRotatedSecs <= _totalRotatedSecsLimit) {
            globalTimer.duration = _totalRotatedSecs;
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
        this._prevAngle = angle;

        globalTimer.stop();
        pomodoroQueue.count > 1 ? pomodoroQueue.restoreDuration(0) : undefined
        pomodoroQueue.infiniteMode = false
        sequence.setCurrentItem(-1)

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
