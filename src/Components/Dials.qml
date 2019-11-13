import QtQuick 2.0

Canvas {

    anchors.rightMargin: 0
    anchors.leftMargin: 0
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottomMargin: 0
    anchors.topMargin: 0

    antialiasing: true

    property real centreX : width / 2
    property real centreY : height / 2

    onPaint: {
        var ctx = getContext("2d");
        ctx.save();
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        function dial(diameter, stroke, color, startSec, endSec) {
            ctx.beginPath();
            ctx.lineWidth = stroke;
            ctx.strokeStyle = color;
            ctx.setLineDash([1, 0]);
            ctx.arc(centreX, centreY, (diameter - stroke) / 2  , startSec / 10 * Math.PI / 180 + 1.5 *Math.PI,  endSec / 10 * Math.PI / 180 + 1.5 *Math.PI);
            ctx.stroke();
        }

        function calibration(diameter, stroke, devisions) {

            var dashWidth = 1

            var clength = Math.PI * (diameter - stroke) / stroke;
            var dash =  dashWidth / stroke
            var space = clength / 180 - dash

            ctx.beginPath();
            ctx.lineWidth = stroke;
            ctx.strokeStyle = appSettings.darkMode ? colors.fakeDark : colors.fakeLight;
            ctx.setLineDash([dash / 2, space, dash / 2, 0]);
            ctx.arc(centreX, centreY, (diameter - stroke) / 2  , 1.5 * Math.PI,  3.5 * Math.PI);
            ctx.stroke();

            var dashWidth2 = 2

            var stroke2 = 4
            var diameter2 = diameter - 2 * stroke - 7

            var clength2 = Math.PI * (diameter2 - stroke2) / stroke2;
            var dash2 = dashWidth2 / stroke2
            var space2 = clength2 / devisions - dash2;


            if (devisions && typeof (devisions) === "number"){

                ctx.beginPath();
                ctx.lineWidth = stroke2;
                ctx.strokeStyle = appSettings.darkMode ? colors.accentDark : colors.accentLight;
                ctx.setLineDash([dash2 / 2, space2, dash2 / 2, 0]);
                ctx.arc(centreX, centreY, (diameter2 - stroke2) / 2  , 1.5 * Math.PI,  3.5 * Math.PI);
                ctx.stroke();

            } else if (devisions) {
                ctx.beginPath();
                ctx.lineWidth = stroke2;
                ctx.strokeStyle = appSettings.darkMode ? colors.fakeDark : colors.fakeLight;
                ctx.setLineDash([1, 0]);
                ctx.arc(centreX, centreY, (diameter2 - stroke2) / 2  , 1.5 * Math.PI,  3.5 * Math.PI);
                ctx.stroke();
            }
        }



        var mainDialTurns = Math.trunc(globalTimer.duration / 3600);

        var turnsDialLine = 2
        var turnsDialPadding = 5

        var mainDialLine = 4
        var mainDialPadding = 8
        var mainDialDiameter = mainDialTurns < 1 ? width : width - (mainDialTurns - 1) * turnsDialPadding - mainDialTurns * turnsDialLine * 2 - mainDialPadding

        var fakeDialLine = 12
        var fakeDialLine2 = 6
        var fakeDialPadding = 8
        var fakeDialDiameter = mainDialDiameter - mainDialLine * 2 - fakeDialPadding

        function mainDialTurn(){
            var t;
            for(t = mainDialTurns; t > 0; t--){
                dial(width - (t - 1) * (turnsDialLine * 2 + turnsDialPadding) , turnsDialLine, appSettings.darkMode ? colors.fakeDark : colors.fakeLight, 0, 3600)
            }

            dial(mainDialDiameter, mainDialLine, appSettings.darkMode ? colors.accentDark : colors.accentLight, 0, globalTimer.duration - (mainDialTurns * 3600))
        }

        mainDialTurn()


        function getSplit(type){
            let splitIncrement;
            let splitColor;
            let splitDuration;

            switch (type) {
            case "pomodoro":
                splitDuration = durationSettings.pomodoro
                splitIncrement = 3600 / durationSettings.pomodoro ;
                splitColor = appSettings.darkMode ? colors.pomodoroDark : colors.pomodoroLight
                break;
            case "pause":
                splitDuration = durationSettings.pause
                splitIncrement = 3600 / durationSettings.pause;
                splitColor = appSettings.darkMode ? colors.shortBreakDark : colors.shortBreakLight
                break;
            case "break":
                splitDuration = durationSettings.breakTime
                splitIncrement = 3600 / durationSettings.breakTime;
                splitColor = appSettings.darkMode ? colors.longBreakDark : colors.longBreakLight
                break;
            default:
                throw "can't calculate split time values";
            }
            return {duration: splitDuration, increment: splitIncrement, color: splitColor};
        }

        if (pomodoroQueue.infiniteMode && globalTimer.running){
            calibration(fakeDialDiameter, fakeDialLine, getSplit(pomodoroQueue.first().type).duration / 60)
            dial(fakeDialDiameter, fakeDialLine,
                 getSplit(pomodoroQueue.first().type).color,
                 0, pomodoroQueue.first().duration * getSplit(pomodoroQueue.first().type).increment )
        } else if (appSettings.splitToSequence) {
            var i;
            var splitVisibleEnd = 0;
            var splitVisibleStart = 0;
            var prevSplit;
            var splitIncrement = 3600 / globalTimer.duration

            calibration(fakeDialDiameter, fakeDialLine, window.clockMode === "start" ? undefined : 12)

            for(i = 0; i <= pomodoroQueue.count - 1; i++){
                i <= 0 ? prevSplit = 0 : prevSplit = pomodoroQueue.get(i-1).duration

                splitVisibleStart = prevSplit + splitVisibleStart;
                splitVisibleEnd = pomodoroQueue.get(i).duration + splitVisibleEnd;

                dial(fakeDialDiameter, fakeDialLine, getSplit(pomodoroQueue.get(i).type).color,
                     splitVisibleStart <= mainDialTurns * 3600 ? mainDialTurns * 3600 : splitVisibleStart,
                     splitVisibleEnd <= mainDialTurns * 3600 ? mainDialTurns * 3600 : splitVisibleEnd
                     )
            }
        } else {
            calibration(fakeDialDiameter, fakeDialLine, window.clockMode === "start" ? undefined : 60)

            dial(fakeDialDiameter, fakeDialLine, appSettings.darkMode ? colors.fakeDark : colors.fakeLight,
                 0, (globalTimer.duration - Math.trunc(globalTimer.duration / 60) * 60) * 60 )
        }
    }

}
