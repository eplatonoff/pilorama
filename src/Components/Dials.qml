import QtQuick

Canvas {
    antialiasing: true

    required property real duration
    required property real splitDuration
    required property real splitTotalDuration
    required property bool isRunning
    required property var splitToSequence
    required property bool dragging

    required property var pomodoroQueue
    required property var masterModel
    required property var colors

    property real centreX: width / 2
    property real centreY: height / 2

    property real mainTurnsWidth: 2
    property real mainTurnsPadding: 6

    property real mainWidth: 4
    property real mainPadding: 8

    property real fakeWidth: 12
    property real fakePadding: 10
    property real fakeDash: 2
    property real fakeGrades: 180

    property real calibrationWidth: 4
    property real calibrationPadding: 7
    property real calibrationDash: 2
    property real calibrationGrades: 12

    property int mainDialTurns: Math.trunc((duration - 1) / 3600)
    property real mainDialDiameter: mainDialTurns
                                    < 1 ? width : width - (mainDialTurns - 1)
                                          * mainTurnsPadding - mainDialTurns
                                          * mainTurnsWidth * 2 - mainPadding
    property real fakeDialDiameter: mainDialDiameter - mainWidth * 2 - fakePadding

    function drawDial(ctx, diameter, stroke, color, startSec, endSec) {
        ctx.beginPath()
        ctx.lineWidth = stroke
        ctx.strokeStyle = color
        ctx.setLineDash([1, 0])
        ctx.arc(centreX, centreY,
                (diameter - stroke) / 2, startSec / 10 * Math.PI / 180 + 1.5
                * Math.PI, endSec / 10 * Math.PI / 180 + 1.5 * Math.PI)
        ctx.stroke()
    }

    function drawCalibration(ctx, diameter, stroke, divisions) {
        const clength = Math.PI * (diameter - stroke) / stroke
        const dash = fakeDash / stroke
        const space = clength / fakeGrades - dash

        ctx.beginPath()
        ctx.lineWidth = stroke
        ctx.strokeStyle = colors.getColor("light")
        ctx.setLineDash([dash / 2, space, dash / 2, 0])
        ctx.arc(centreX, centreY, (diameter - stroke) / 2, 1.5 * Math.PI,
                3.5 * Math.PI)
        ctx.stroke()

        const diameter2 = diameter - 2 * stroke - calibrationPadding
        const clength2 = Math.PI * (diameter2 - calibrationWidth) / calibrationWidth
        const dash2 = calibrationDash / calibrationWidth
        const space2 = clength2 / divisions - dash2

        ctx.beginPath()
        ctx.lineWidth = calibrationWidth
        ctx.strokeStyle = colors.getColor(
                    divisions
                    && typeof divisions === "number" ? 'mid' : 'light')
        ctx.setLineDash(
                    divisions
                    && typeof divisions === "number" ? [dash2 / 2, space2, dash2 / 2, 0] : [1, 0])
        ctx.arc(centreX, centreY, (diameter2 - calibrationWidth) / 2,
                1.5 * Math.PI, 3.5 * Math.PI)
        ctx.stroke()
    }

    function drawMainDialTurns(ctx) {
        for (let t = mainDialTurns; t > 0; t--) {
            drawDial(ctx, width - (t - 1) * (mainTurnsWidth * 2 + mainTurnsPadding),
                     mainTurnsWidth, colors.getColor('light'), 0, 3600)
        }
        drawDial(ctx, mainDialDiameter, mainWidth, colors.getColor('mid'), 0,
                 duration - (mainDialTurns * 3600))
    }

    property bool displayInfiniteMode: pomodoroQueue.infiniteMode || splitToSequence

    function drawCalibrationMarks(ctx) {
        if (pomodoroQueue.infiniteMode) {
            drawCalibration(ctx, width, fakeWidth, masterModel.get(
                                pomodoroQueue.first().id).duration / 60)
        } else if (!pomodoroQueue.infiniteMode && !isRunning && duration) {
            drawCalibration(ctx, duration > 0 ? fakeDialDiameter : width,
                            fakeWidth, 12)
        } else {
            drawCalibration(ctx, duration > 0 ? fakeDialDiameter : width,
                            fakeWidth, 60)
        }
    }

    function ensureMinimumTurn(value, mainTurnSeconds) {
        return value <= mainTurnSeconds ? mainTurnSeconds : value
    }

    function drawSplitSequenceDial(ctx, dialDiameter, mainTurnSeconds) {
        let splitVisibleEnd = 0
        let splitVisibleStart = 0
        let prevSplit = 0
        for (let i = 0; i <= pomodoroQueue.count - 1; i++) {
            prevSplit = i <= 0 ? 0 : pomodoroQueue.get(i - 1).duration
            splitVisibleStart += prevSplit
            splitVisibleEnd += pomodoroQueue.get(i).duration
            const splitColor = masterModel.get(pomodoroQueue.get(i).id).color

            drawDial(ctx, dialDiameter, fakeWidth,
                     colors.getColor(splitColor),
                     ensureMinimumTurn(splitVisibleStart, mainTurnSeconds),
                     ensureMinimumTurn(splitVisibleEnd, mainTurnSeconds))
        }
    }

    function drawPomodoroDial(ctx) {
        const mainTurnSeconds = mainDialTurns * 3600

        if (pomodoroQueue.infiniteMode || (splitToSequence && isRunning)) {
            const firstQueueItem = pomodoroQueue.get(0)
            const firstColor = masterModel.get(firstQueueItem.id).color
            const splitSweep = splitTotalDuration > 0
                               ? splitDuration * 3600 / splitTotalDuration
                               : 0
            const dialDiameter = pomodoroQueue.infiniteMode ? width : fakeDialDiameter

            drawDial(ctx, dialDiameter, fakeWidth,
                     colors.getColor(firstColor), 0, splitSweep)
        } else if (splitToSequence && dragging) {
            drawSplitSequenceDial(ctx, fakeDialDiameter, mainTurnSeconds)
        } else {
            const totalDuration = splitTotalDuration > 0 ? splitTotalDuration : duration
            const progressSweep = dragging
                                  ? duration - mainTurnSeconds
                                  : (totalDuration > 0 ? duration * 3600 / totalDuration : 0)
            drawDial(ctx, fakeDialDiameter, fakeWidth,
                     colors.getColor('light'), 0,
                     progressSweep)
        }
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.save()
        ctx.clearRect(0, 0, width, height)

        drawMainDialTurns(ctx)
        drawCalibrationMarks(ctx)
        drawPomodoroDial(ctx)

        ctx.restore()
    }
}
