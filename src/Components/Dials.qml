import QtQuick

Canvas {
    anchors.fill: parent
    antialiasing: true

    property real centreX : width / 2
    property real centreY : height / 2

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

    property real duration: globalTimer.duration
    property real splitDuration: globalTimer.splitDuration

    onPaint: {
        var ctx = getContext("2d");
        ctx.save();
        ctx.clearRect(0, 0, width, height);

        function dial(diameter, stroke, color, startSec, endSec) {
            ctx.beginPath();
            ctx.lineWidth = stroke;
            ctx.strokeStyle = color;
            ctx.setLineDash([1, 0]);
            ctx.arc(centreX, centreY, (diameter - stroke) / 2  , startSec / 10 * Math.PI / 180 + 1.5 *Math.PI,  endSec / 10 * Math.PI / 180 + 1.5 *Math.PI);
            ctx.stroke();
        }

        function calibration(diameter, stroke, devisions) {

            var clength = Math.PI * (diameter - stroke) / stroke;
            var dash =  fakeDash / stroke
            var space = clength / fakeGrades - dash

            ctx.beginPath();
            ctx.lineWidth = stroke;
            ctx.strokeStyle = colors.getColor("light")
            ctx.setLineDash([dash / 2, space, dash / 2, 0]);
            ctx.arc(centreX, centreY, (diameter - stroke) / 2  , 1.5 * Math.PI,  3.5 * Math.PI);
            ctx.stroke();

            var diameter2 = diameter - 2 * stroke - calibrationPadding

            var clength2 = Math.PI * (diameter2 - calibrationWidth) / calibrationWidth;
            var dash2 = calibrationDash / calibrationWidth
            var space2 = clength2 / devisions - dash2;

            if (devisions && typeof (devisions) === "number"){

                ctx.beginPath();
                ctx.lineWidth = calibrationWidth;
                ctx.strokeStyle = colors.getColor('mid');
                ctx.setLineDash([dash2 / 2, space2, dash2 / 2, 0]);
                ctx.arc(centreX, centreY, (diameter2 - calibrationWidth) / 2  , 1.5 * Math.PI,  3.5 * Math.PI);
                ctx.stroke();

            } else if (devisions) {
                ctx.beginPath();
                ctx.lineWidth = calibrationWidth;
                ctx.strokeStyle = colors.getColor('light');
                ctx.setLineDash([1, 0]);
                ctx.arc(centreX, centreY, (diameter2 - calibrationWidth) / 2  , 1.5 * Math.PI,  3.5 * Math.PI);
                ctx.stroke();
            }
        }

        var mainDialTurns = Math.trunc((duration - 1) / 3600);
        var mainDialDiameter = mainDialTurns < 1 ? width : width - (mainDialTurns - 1) * mainTurnsPadding - mainDialTurns * mainTurnsWidth * 2 - mainPadding
        var fakeDialDiameter = mainDialDiameter - mainWidth * 2 - fakePadding

        function mainDialTurn(){
            var t;
            for(t = mainDialTurns; t > 0; t--){
                dial(width - (t - 1) * (mainTurnsWidth * 2 + mainTurnsPadding) , mainTurnsWidth, colors.getColor('light'), 0, 3600)
            }

            dial(mainDialDiameter, mainWidth, colors.getColor('mid'), 0, duration - (mainDialTurns * 3600))
        }

        mainDialTurn()


        if (pomodoroQueue.infiniteMode){
            calibration(width, fakeWidth, masterModel.get(pomodoroQueue.first().id).duration / 60)
        } else if (!pomodoroQueue.infiniteMode && !globalTimer.running && duration){
            calibration(duration > 0 ? fakeDialDiameter : width, fakeWidth, 12)
        } else {
            calibration(duration > 0 ? fakeDialDiameter : width, fakeWidth, 60)
        }

        if (pomodoroQueue.infiniteMode){

            dial(width, fakeWidth,
                 colors.getColor(masterModel.get(pomodoroQueue.get(0).id).color),
                 0, splitDuration * 3600 / masterModel.get(pomodoroQueue.first().id).duration )

        } else if (!pomodoroQueue.infiniteMode && appSettings.splitToSequence ){

            var splitVisibleEnd = 0;
            var splitVisibleStart = 0;
            var splitColor;
            var prevSplit = 0
            var splitIncrement = 3600 / duration

            for(let i = 0; i <= pomodoroQueue.count - 1; i++){
                i <= 0 ? prevSplit = 0 : prevSplit = pomodoroQueue.get(i-1).duration

                splitVisibleStart = prevSplit + splitVisibleStart;
                splitVisibleEnd = pomodoroQueue.get(i).duration + splitVisibleEnd;
                splitColor = masterModel.get(pomodoroQueue.get(i).id).color

                dial(fakeDialDiameter, fakeWidth, colors.getColor(splitColor),
                     splitVisibleStart <= mainDialTurns * 3600 ? mainDialTurns * 3600 : splitVisibleStart,
                     splitVisibleEnd <= mainDialTurns * 3600 ? mainDialTurns * 3600 : splitVisibleEnd
                     )
            }
        } else {
            dial(fakeDialDiameter, fakeWidth, colors.getColor('light'), 0, duration - (mainDialTurns * 3600) )
        }


    }

}
