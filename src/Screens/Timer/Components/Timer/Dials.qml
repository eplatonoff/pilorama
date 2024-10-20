import QtQuick

Canvas {
    id: canvas

    required property var burnerModel
    property real calibrationDash: 2
    property real calibrationGrades: 12
    property real calibrationPadding: 7
    property real calibrationWidth: 4
    property real centreX: width / 2
    property real centreY: height / 2
    required property real duration
    property real fakeDash: 1
    property real fakeDialDiameter: mainDialDiameter - mainWidth * 2 - fakePadding
    property real fakeGrades: 240
    property real fakePadding: 10
    property real fakeWidth: 12
    required property bool isRunning
    property real mainDialDiameter: mainDialTurns < 1 ? width : width - (mainDialTurns - 1) * mainTurnsPadding - mainDialTurns * mainTurnsWidth * 2 - mainPadding
    property int mainDialTurns: Math.trunc((duration - 1) / 3600)
    property real mainPadding: 8
    property real mainTurnsPadding: 6
    property real mainTurnsWidth: 2
    property real mainWidth: 4
    required property real splitDuration
    required property var splitToSequence
    required property var timerModel

    function drawCalibration(ctx, diameter, stroke, divisions) {
        var clength = Math.PI * (diameter - stroke) / stroke;
        var dash = fakeDash / stroke;
        var space = clength / fakeGrades - dash;
        ctx.beginPath();
        ctx.lineWidth = stroke;
        ctx.strokeStyle = colors.getColor("light");
        ctx.setLineDash([dash / 2, space, dash / 2, 0]);
        ctx.arc(centreX, centreY, (diameter - stroke) / 2, 1.5 * Math.PI, 3.5 * Math.PI);
        ctx.stroke();
        var diameter2 = diameter - 2 * stroke - calibrationPadding;
        var clength2 = Math.PI * (diameter2 - calibrationWidth) / calibrationWidth;
        var dash2 = calibrationDash / calibrationWidth;
        var space2 = clength2 / divisions - dash2;
        ctx.beginPath();
        ctx.lineWidth = calibrationWidth;
        ctx.strokeStyle = colors.getColor(divisions && typeof divisions === "number" ? 'mid' : 'light');
        ctx.setLineDash(divisions && typeof divisions === "number" ? [dash2 / 2, space2, dash2 / 2, 0] : [1, 0]);
        ctx.arc(centreX, centreY, (diameter2 - calibrationWidth) / 2, 1.5 * Math.PI, 3.5 * Math.PI);
        ctx.stroke();
    }
    function drawCalibrationMarks(ctx) {
        if (!isRunning && duration) {
            drawCalibration(ctx, duration > 0 ? fakeDialDiameter : width, fakeWidth, 12);
        } else {
            drawCalibration(ctx, duration > 0 ? fakeDialDiameter : width, fakeWidth, 60);
        }
    }
    function drawDial(ctx, diameter, stroke, color, startSec, endSec) {
        ctx.beginPath();
        ctx.lineWidth = stroke;
        ctx.strokeStyle = color;
        ctx.setLineDash([1, 0]);
        ctx.arc(centreX, centreY, (diameter - stroke) / 2, startSec / 10 * Math.PI / 180 + 1.5 * Math.PI, endSec / 10 * Math.PI / 180 + 1.5 * Math.PI);
        ctx.stroke();
    }
    function drawMainDialTurns(ctx) {
        for (var t = mainDialTurns; t > 0; t--) {
            drawDial(ctx, width - (t - 1) * (mainTurnsWidth * 2 + mainTurnsPadding), mainTurnsWidth, colors.getColor('light'), 0, 3600);
        }
        drawDial(ctx, mainDialDiameter, mainWidth, colors.getColor('mid'), 0, duration - (mainDialTurns * 3600));
    }
    function drawTimerDial(ctx) {
        var splitVisibleEnd = 0;
        var splitVisibleStart = 0;
        var splitColor;
        var prevSplit = 0;
        var splitIncrement = 3600 / duration;
        for (var i = 0; i <= burnerModel.count - 1; i++) {
            prevSplit = i <= 0 ? 0 : burnerModel.get(i - 1).duration;
            splitVisibleStart = prevSplit + splitVisibleStart;
            splitVisibleEnd = burnerModel.get(i).duration + splitVisibleEnd;
            splitColor = timerModel.get(burnerModel.get(i).id).color;
            drawDial(ctx, fakeDialDiameter, fakeWidth, colors.getColor(splitColor), splitVisibleStart <= mainDialTurns * 3600 ? mainDialTurns * 3600 : splitVisibleStart, splitVisibleEnd <= mainDialTurns * 3600 ? mainDialTurns * 3600 : splitVisibleEnd);
        }
    }

    antialiasing: true

    onPaint: {
        var ctx = getContext("2d");
        ctx.save();
        ctx.clearRect(0, 0, width, height);
        drawMainDialTurns(ctx);
        drawCalibrationMarks(ctx);
        drawTimerDial(ctx);
        ctx.restore();
    }
}
