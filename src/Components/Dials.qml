import QtQuick

Canvas {
    antialiasing: true

    required property real duration
    required property real splitDuration
    required property bool isRunning
    required property var splitToSequence

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
        var clength = Math.PI * (diameter - stroke) / stroke
        var dash = fakeDash / stroke
        var space = clength / fakeGrades - dash

        ctx.beginPath()
        ctx.lineWidth = stroke
        ctx.strokeStyle = colors.getColor("light")
        ctx.setLineDash([dash / 2, space, dash / 2, 0])
        ctx.arc(centreX, centreY, (diameter - stroke) / 2, 1.5 * Math.PI,
                3.5 * Math.PI)
        ctx.stroke()

        var diameter2 = diameter - 2 * stroke - calibrationPadding
        var clength2 = Math.PI * (diameter2 - calibrationWidth) / calibrationWidth
        var dash2 = calibrationDash / calibrationWidth
        var space2 = clength2 / divisions - dash2

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
        for (var t = mainDialTurns; t > 0; t--) {
            drawDial(ctx,
                     width - (t - 1) * (mainTurnsWidth * 2 + mainTurnsPadding),
                     mainTurnsWidth, colors.getColor('light'), 0, 3600)
        }
        drawDial(ctx, mainDialDiameter, mainWidth, colors.getColor('mid'), 0,
                 duration - (mainDialTurns * 3600))
    }

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

    function drawPomodoroDial(ctx) {
        if (pomodoroQueue.infiniteMode) {
            drawDial(ctx, width, fakeWidth, colors.getColor(
                         masterModel.get(pomodoroQueue.get(0).id).color), 0,
                     splitDuration * 3600 / masterModel.get(pomodoroQueue.first(
                                                                ).id).duration)
        } else if (!pomodoroQueue.infiniteMode && splitToSequence) {
            var splitVisibleEnd = 0
            var splitVisibleStart = 0
            var splitColor
            var prevSplit = 0
            var splitIncrement = 3600 / duration

            for (var i = 0; i <= pomodoroQueue.count - 1; i++) {
                prevSplit = i <= 0 ? 0 : pomodoroQueue.get(i - 1).duration
                splitVisibleStart = prevSplit + splitVisibleStart
                splitVisibleEnd = pomodoroQueue.get(
                            i).duration + splitVisibleEnd
                splitColor = masterModel.get(pomodoroQueue.get(i).id).color

                drawDial(ctx, fakeDialDiameter, fakeWidth, colors.getColor(
                             splitColor), splitVisibleStart
                         <= mainDialTurns * 3600 ? mainDialTurns
                                                   * 3600 : splitVisibleStart, splitVisibleEnd
                         <= mainDialTurns * 3600 ? mainDialTurns * 3600 : splitVisibleEnd)
            }
        } else {
            drawDial(ctx, fakeDialDiameter, fakeWidth,
                     colors.getColor('light'), 0,
                     duration - (mainDialTurns * 3600))
        }
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.save()
        ctx.clearRect(0, 0, width, height)

        drawMainDialTurns(ctx)
        drawCalibrationMarks(ctx)
        drawPomodoroDial(ctx)

        ctx.restore()
    }
}
