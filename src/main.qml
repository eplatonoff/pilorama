import QtQuick 2.13
import QtQuick.Window 2.13
import QtGraphicalEffects 1.12
import QtMultimedia 5.13

import "utils/geometry.mjs" as GeometryScripts

import notifications 1.0


Window {
    id: window
    visible: true
    width: 300
    height: 300
    color: darkMode ? colors.bgDark : colors.bgLight
    title: qsTr("qml timer")

    property string clockMode: "start"
    property bool darkMode: false
    property bool soundOn: true
    property bool showPrefs: false

    onDarkModeChanged: { canvas.requestPaint()}
    onShowPrefsChanged: { canvas.requestPaint()}
    onClockModeChanged: { canvas.requestPaint()}

    function checkClockMode (){
        if (pomodoroQueue.infiniteMode && globalTimer.running){
            clockMode = "pomodoro"
        } else if (!pomodoroQueue.infiniteMode){
            clockMode = "timer"
        } else {
            clockMode = "start"
        }
    }

    NotificationSystem {
        id: notifications

        default property bool soundMuted: false

        property SoundEffect sound: SoundEffect {
            id: soundNotification
            muted: notifications.soundMuted
            source: "./sound/piano-low.wav"
        }

        function stopSound() {
            soundNotification.stop();
        }

        function sendWithSound(type) {
            soundNotification.play();
            send(type);
        }

        function sendFromItem(item) {
            switch (item.type) {
            case "pomodoro":
                sendWithSound(NotificationSystem.POMODORO); break;
            case "pause":
                sendWithSound(NotificationSystem.PAUSE); break;
            case "break":
                sendWithSound(NotificationSystem.BREAK); break;
            default:
                throw "unknown time segment type";
            }
        }
    }


    PomodoroModel {
        id: pomodoroQueue
        durationSettings: durationSettings
    }

    QtObject {
        id: durationSettings

        property real pomodoro: 25 * 60
        property real pause: 10 * 60
        property real breakTime: 15 * 60
        property int repeatBeforeBreak: 2
    }

    Item {
        id: colors
        property color bgLight: "#EFEEE9"
        property color bgDark: "#282828"

        property color fakeDark: "#4F5655"
        property color fakeLight: "#CEC9B6"

        property color accentDark: "#859391"
        property color accentLight: "#968F7E"

        property color accentTextDark: "#fff"
        property color accentTextLight: "#000"

        property color pomodoroLight: "#E26767"
        property color pomodoroDark: "#C23E3E"

        property color shortBreakLight: "#7DCF6F"
        property color shortBreakDark: "#5BB44C"

        property color longBreakLight: "#6F85CF"
        property color longBreakDark: "#5069BE"
    }

    Timer {
        id: globalTimer
        property real duration: 0
        property real splitDuration: 0

        property int secsInterval: Math.trunc(interval / 1000)

        onDurationChanged: {
            window.checkClockMode();
            time.updateTime();
            canvas.requestPaint();
        }

        interval: 1000
        running: false
        repeat: true

        onTriggered: {

            if (!pomodoroQueue.infiniteMode) {
                if (duration >= 1){
                    duration--;
                } else {
                    notifications.sendWithSound(NotificationSystem.STOP);
                    window.clockMode = "start";
                    stop();
                }
            }

            const firstItem = pomodoroQueue.first();

            if (firstItem) {
                splitDuration = firstItem.duration;

                if (splitDuration === pomodoroQueue.itemDurationBound(firstItem)) {
                    notifications.sendFromItem(firstItem);
                }
            } else
                splitDuration = 0;

            pomodoroQueue.drainTime(secsInterval);

            time.updateTime();

            canvas.requestPaint();
        }
    }

    QtObject {
        id: time
        property real hours: 0
        property real minutes: 0
        property real seconds: 0

        function updateTime(){
            var currentDate = new Date()
            hours = currentDate.getHours()
            minutes = currentDate.getMinutes()
            seconds = currentDate.getSeconds()
        }
    }



    Item {
        id: content
        anchors.rightMargin: 16
        anchors.leftMargin: 16
        anchors.bottomMargin: 16
        anchors.topMargin: 16
        anchors.fill: parent

        Item {
            id: timerLayout
            anchors.fill: parent
            visible: !window.showPrefs

            Canvas {

                id: canvas

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
                        ctx.strokeStyle = window.darkMode ? colors.fakeDark : colors.fakeLight;
                        ctx.setLineDash([dash / 2, space, dash / 2, 0]);
                        ctx.arc(centreX, centreY, (diameter - stroke) / 2  , 1.5 * Math.PI,  3.5 * Math.PI);
                        ctx.stroke();

                        if (devisions){

                        var dashWidth2 = 2

                        var stroke2 = 4
                        var diameter2 = diameter - 2 * stroke - 7
//                        var diameter2 = diameter

                        var clength2 = Math.PI * (diameter2 - stroke2) / stroke2;
                        var dash2 = dashWidth2 / stroke2
                        var space2 = clength2 / devisions - dash2;

                        ctx.beginPath();
                        ctx.lineWidth = stroke2;
                        ctx.strokeStyle = window.darkMode ? colors.accentDark : colors.accentLight;
                        ctx.setLineDash([dash2 / 2, space2, dash2 / 2, 0]);
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

//                    dial(fakeDialDiameter, fakeDialLine, 12, window.darkMode ? colors.fakeDark : colors.fakeLight, 0, 3600)
//                    dial(fakeDialDiameter, fakeDialLine2, 60, window.darkMode ? colors.fakeDark : colors.fakeLight, 0, 3600)

                    function mainDialTurn(){
                        var t;
                        for(t = mainDialTurns; t > 0; t--){
                            dial(width - (t - 1) * (turnsDialLine * 2 + turnsDialPadding) , turnsDialLine, window.darkMode ? colors.fakeDark : colors.fakeLight, 0, 3600)
                        }

                        dial(mainDialDiameter, mainDialLine, window.darkMode ? colors.accentDark : colors.accentLight, 0, globalTimer.duration - (mainDialTurns * 3600))
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
                            splitColor = window.darkMode ? colors.pomodoroDark : colors.pomodoroLight
                            break;
                        case "pause":
                            splitDuration = durationSettings.pause
                            splitIncrement = 3600 / durationSettings.pause;
                            splitColor = window.darkMode ? colors.shortBreakDark : colors.shortBreakLight
                            break;
                        case "break":
                            splitDuration = durationSettings.breakTime
                            splitIncrement = 3600 / durationSettings.breakTime;
                            splitColor = window.darkMode ? colors.longBreakDark : colors.longBreakLight
                            break;
                        default:
                            throw "can't calculate split time values";
                        }
                        return {duration: splitDuration, increment: splitIncrement, color: splitColor};
                    }

                    if (globalTimer.running){
                        calibration(fakeDialDiameter, fakeDialLine, getSplit(pomodoroQueue.first().type).duration / 60)
                        dial(fakeDialDiameter, fakeDialLine,
                             getSplit(pomodoroQueue.first().type).color,
                             0, pomodoroQueue.first().duration * getSplit(pomodoroQueue.first().type).increment )
                    } else {
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

//                            dial(fakeDialDiameter, fakeDialLine, false, getSplit(pomodoroQueue.get(i).type).color,
//                                 splitVisibleStart * splitIncrement,
//                                 splitVisibleEnd * splitIncrement
//                                 )
                        }
                    }

                    //                                ctx.beginPath();
                    //                                ctx.lineWidth = 2;
                    //                                ctx.strokeStyle = "black";
                    //                                ctx.moveTo(mouseArea.circleStart.x, mouseArea.circleStart.y);
                    //                                ctx.lineTo(mouseArea.mousePoint.x, mouseArea.mousePoint.y);
                    //                                ctx.lineTo(centreX, centreY);
                    //                                ctx.lineTo(mouseArea.circleStart.x, mouseArea.circleStart.y);
                    //                                ctx.stroke();
                }


                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    propagateComposedEvents: true

                    signal rotated(real delta)

                    property point circleStart: Qt.point(0, 0)
                    property point mousePoint: Qt.point(0, 0)
                    property real scroll: 0
                    property real scrollMultiplier: 5

                    property real _prevAngle: 0
                    property real _totalRotated: 0
                    property real _totalRotatedSecs: 0

//                    function roundToPrecision(value, maxValue, precision) {
//                        var y = value + precision / 2;
//                        return y - y % +precision;
//                        var y = 1 / (1 + Math.exp(-Math.abs(value)))
//                        var y = Math.atan(value) * maxValue / precision
//                        return value * y
//                    }

                    onReleased: {
                        if (globalTimer.duration > 0) {
                            globalTimer.start()

                        }  else {
                            globalTimer.stop();
                            window.clockMode = "start"
                            soundNotification.stop()
                        }
                    }

                    onRotated: {

                        const deltaSecs = delta * 10;

                        this._totalRotated += delta;
                        this._totalRotatedSecs += deltaSecs;

                        pomodoroQueue.changeQueue(deltaSecs);

                        console.log(delta)

                        if (_totalRotatedSecs >= 0) {
                            globalTimer.duration = _totalRotatedSecs;
                        } else {
                            _totalRotatedSecs = 0;
                        }
                    }

                    onPressed: {

                        const angle = GeometryScripts.mouseAngle(
                                        Qt.point(mouse.x, mouse.y),
                                        Qt.point(canvas.centreX, canvas.centreY));
                        this._prevAngle = angle;

                        pomodoroQueue.infiniteMode = false
                    }

                    onPositionChanged: {
                        globalTimer.stop();

                        const angle = GeometryScripts.mouseAngle(
                                        Qt.point(mouse.x, mouse.y),
                                        Qt.point(canvas.centreX, canvas.centreY));


                        const delta = GeometryScripts.lessDelta(angle, this._prevAngle);

                        this._prevAngle = angle;

                        this.rotated(delta);
                    }

                }

            }

            Item {
                id: startControls
                visible: window.clockMode === "start"
                width: 140
                height: 140
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: startPomoIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    sourceSize.height: 45
                    sourceSize.width: 45
                    antialiasing: true
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: "./img/play.svg"

                    ColorOverlay{
                        id: startPomoOverlay
                        anchors.fill: parent
                        source: parent
                        color: window.darkMode ? colors.pomodoroDark : colors.pomodoroLight
                        antialiasing: true
                    }

                    MouseArea {
                        id: startPomoTrigger
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        cursorShape: Qt.PointingHandCursor

                        onReleased: {
                            window.clockMode = "pomodoro"
                            pomodoroQueue.infiniteMode = true
                            globalTimer.start()
                        }
                    }
                }

                Column {
                    id: column
                    y: 54
                    width: 54
                    height: 46
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    anchors.left: startPomoIcon.right
                    anchors.leftMargin: 9

                    Item {
                        id: pomodoroLine
                        height: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        Rectangle {
                            width: 7
                            height: 7
                            radius: 20
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 0
                            color: window.darkMode ? colors.pomodoroDark : colors.pomodoroLight
                        }

                        Text {
                            height: 11
                            text: (durationSettings.pomodoro / 60) + " min"
                            verticalAlignment: Text.AlignVCenter
                            color: window.darkMode ? colors.accentTextDark : colors.accentTextLight
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            font.pixelSize: 11
                        }

                    }
                    Item {
                        id: shortBreakLine
                        height: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        Rectangle {
                            width: 7
                            height: 7
                            radius: 20
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 0
                            color: window.darkMode ? colors.shortBreakDark : colors.shortBreakLight
                        }

                        Text {
                            height: 11
                            text: (durationSettings.pause / 60) + " min"
                            verticalAlignment: Text.AlignVCenter
                            color: window.darkMode ? colors.accentTextDark : colors.accentTextLight
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            font.pixelSize: 11
                        }

                    }
                    Item {
                        id: longBreakLine
                        height: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        Rectangle {
                            width: 7
                            height: 7
                            radius: 20
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 0
                            color: window.darkMode ? colors.longBreakDark : colors.longBreakLight
                        }

                        Text {
                            height: 11
                            text: (durationSettings.breakTime / 60) + " min"
                            verticalAlignment: Text.AlignVCenter
                            color: window.darkMode ? colors.accentTextDark : colors.accentTextLight
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            font.pixelSize: 11
                        }

                    }
                }
            }

            Item {
                id: digitalClock
                visible: window.clockMode === "pomodoro" || window.clockMode === "timer"
                width: 140
                height: 140
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                property string min: "00"
                property string sec: "00"

                function pad(value){
                    if (value < 10) {return "0" + value
                    } else {return value}
                }

                Image {
                    id: bellIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 37
                    anchors.top: parent.top
                    anchors.topMargin: 25
                    sourceSize.height: 16
                    sourceSize.width: 16
                    source: "./img/bell.svg"
                    antialiasing: true
                    fillMode: Image.PreserveAspectFit

                    ColorOverlay{
                        id: bellIconOverlay
                        anchors.fill: parent
                        source: parent
                        color: darkMode ? colors.accentDark : colors.accentLight
                        antialiasing: true
                    }
                }

                Text {
                    id: digitalTime
                    width: 80
                    height: 15
                    text: showFuture()
                    font.bold: true
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: bellIcon.verticalCenter
                    anchors.left: bellIcon.right
                    anchors.leftMargin: 1
                    anchors.bottom: digitalMin.top
                    anchors.bottomMargin: 5
                    horizontalAlignment: Text.AlignLeft
                    color: darkMode ? colors.accentDark : colors.accentLight

                    function showFuture() {
                        var extraTime;
                        if (!pomodoroQueue.infiniteMode){
                            extraTime = globalTimer.duration
                        } else {
                            switch (pomodoroQueue.first().type) {
                            case "pomodoro":
                                extraTime = durationSettings.pomodoro
                                break;
                            case "pause":
                                extraTime =  durationSettings.pause;
                                break;
                            case "break":
                                extraTime = durationSettings.breakTime;
                                break;
                            default:
                                throw "can't calculate notification time";
                            }

                        }
                        var future = time.hours * 3600 + time.minutes *60 + time.seconds + extraTime
                        var h = Math.trunc(future / 3600)
                        var m = Math.trunc((future - h * 3600) / 60)
                        return parent.pad(h) + ":" + parent.pad(m)
                    }

                }

                Text {
                    id: digitalSec
                    width: 51
                    text: seconds();
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignTop
                    anchors.top: digitalMin.top
                    anchors.topMargin: 6
                    anchors.left: digitalMin.right
                    anchors.leftMargin: 3
                    font.pixelSize: 22
                    color: darkMode ? colors.accentTextDark : colors.accentTextLight

                    function seconds(){
                        if (pomodoroQueue.infiniteMode === true){
                            return parent.pad(Math.trunc(globalTimer.splitDuration % 60))
                        } else if(!pomodoroQueue.infiniteMode && !globalTimer.running) {
                            return "min"
                        }else {
                            return parent.pad(Math.trunc(globalTimer.duration % 60))
                        }
                    }
                }

                Text {
                    id: digitalMin
                    width: 60
                    text: minutes()
                    anchors.top: parent.top
                    anchors.topMargin: 38
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignTop
                    anchors.left: parent.left
                    anchors.leftMargin: 26
                    font.pixelSize: 44
                    color: darkMode ? colors.accentTextDark : colors.accentTextLight

                    function minutes(){
                        if (pomodoroQueue.infiniteMode){
                            return parent.pad(Math.trunc(globalTimer.splitDuration / 60))
                        } else {
                            return parent.pad(Math.trunc(globalTimer.duration / 60))
                        }
                    }
                }



                Rectangle {
                    id: rectangle
                    height: 38
                    color: "transparent"
                    border.color: darkMode ? colors.fakeDark : colors.fakeLight
                    border.width: 2
                    radius: 22.5

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    anchors.left: parent.left
                    anchors.leftMargin: 15

                    Text {
                        id: digitalClockReset
                        text: qsTr("reset timer")
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        anchors.fill: parent
                        font.pixelSize: 14
                        color: darkMode ? colors.accentDark : colors.accentLight

                        MouseArea {
                            id: digitalClockResetTrigger
                            anchors.fill: parent
                            hoverEnabled: true
                            propagateComposedEvents: true
                            cursorShape: Qt.PointingHandCursor

                            onReleased: {
                                pomodoroQueue.infiniteMode = false;
                                pomodoroQueue.clear();
                                mouseArea._prevAngle = 0
                                mouseArea._totalRotatedSecs = 0
                                globalTimer.duration = 0
                                globalTimer.stop()
                                window.clockMode = "start"
                                notifications.stopSound();
                            }
                        }
                    }
                }
            }

            Image {
                id: soundIcon
                anchors.left: parent.left
                anchors.leftMargin: 0
                sourceSize.height: 23
                sourceSize.width: 23
                source: "./img/sound.svg"
                antialiasing: true
                fillMode: Image.PreserveAspectFit

                property bool soundOn: true
                property color color: colors.fakeLight

                property string iconSound: "./img/sound.svg"
                property string iconNoSound: "./img/nosound.svg"

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0


                onSoundOnChanged: {
                    if ( soundOn ){
                        soundIcon.source = iconSound;
                        notifications.soundMuted = false;
                    } else {
                        notifications.stopSound()
                        soundIcon.source = iconNoSound;
                        notifications.soundMuted = true;
                    }

                }

                ColorOverlay{
                    id: soundIconOverlay
                    anchors.fill: parent
                    source: parent
                    color: window.darkMode ? colors.fakeDark : colors.fakeLight
                    antialiasing: true
                }

                MouseArea {
                    id: soundIconTrigger
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    cursorShape: Qt.PointingHandCursor

                    onReleased: {
                        soundIcon.soundOn = !soundIcon.soundOn
                    }
                }
            }



        }

        Item {
            id: prefsLayout
            anchors.bottomMargin: 0
            anchors.topMargin: 40

            anchors.fill: parent
            visible: window.showPrefs

            Rectangle {
                id: lineDivider
                height: 1
                color: darkMode ? colors.fakeDark : colors.fakeLight
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
            }

            Item {
                id: sliceLine
                height: 50
                anchors.top: lineDivider.bottom
                anchors.topMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                property real dotSize: 10
                property real dotSpacing: 3

                Rectangle {
                    id: dotPomo
                    width: parent.dotSize
                    height: parent.dotSize
                    color: darkMode ? colors.pomodoroDark : colors.pomodoroLight
                    radius: 30
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: dotShortBreak
                    width: parent.dotSize
                    height: parent.dotSize
                    color: darkMode ? colors.shortBreakDark : colors.shortBreakLight
                    radius: 30
                    anchors.left: dotPomo.right
                    anchors.leftMargin: parent.dotSpacing
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: dotLongBreak
                    width: parent.dotSize
                    height: parent.dotSize
                    color: darkMode ? colors.longBreakDark : colors.longBreakLight
                    radius: 30
                    anchors.left: dotShortBreak.right
                    anchors.leftMargin: parent.dotSpacing
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: timeSet
                    width: 30
                    color: darkMode ? colors.accentTextDark : colors.accentTextLight
                    text: pomodoro.duration
                    horizontalAlignment: Text.AlignRight
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 16

                    onTextChanged: {pomodoro.duration = timeSet.text}
                }

                Text {
                    id: minLabel
                    width: 30
                    text: qsTr("min")
                    color: darkMode ? colors.accentTextDark : colors.accentTextLight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: timeSet.right
                    anchors.leftMargin: 3
                    font.pixelSize: 16
                }

                Image {
                    id: soundLineIcon
                    sourceSize.height: 23
                    sourceSize.width: 23
                    source: "./img/sound.svg"
                    antialiasing: true
                    fillMode: Image.PreserveAspectFit

                    property bool soundOn: true
                    property color color: colors.fakeLight

                    property string iconSound: "./img/sound.svg"
                    property string iconNoSound: "./img/nosound.svg"
                    x: 99
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 0


                    onSoundOnChanged: {
                        soundOn ? source = iconSound : source = iconNoSound
                    }

                    ColorOverlay{
                        anchors.fill: parent
                        source: parent
                        color: window.darkMode ? colors.fakeDark : colors.fakeLight
                        antialiasing: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        cursorShape: Qt.PointingHandCursor

                        onReleased: {
                            parent.soundOn = !parent.soundOn
                        }
                    }
                }

            }

        }

        Image {
            id: prefsIcon
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            source: "./img/prefs.svg"
            fillMode: Image.PreserveAspectFit

            property bool prefsToggle: false

            ColorOverlay{
                id: prefsIconOverlay
                anchors.fill: parent
                source: parent
                color: window.darkMode ? colors.fakeDark : colors.fakeLight
                antialiasing: true
            }

            MouseArea {
                id: prefsIconTrigger
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    window.showPrefs = !window.showPrefs
                }
            }
        }
        Image {
            id: modeSwitch
            sourceSize.width: 23
            sourceSize.height: 23
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit

            property string iconDark: "./img/sun.svg"
            property string iconLight: "./img/moon.svg"
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            source: window.darkMode ? iconDark : iconLight

            ColorOverlay{
                id: modeSwitchOverlay
                anchors.fill: parent
                source: parent
                color: window.darkMode ? colors.fakeDark : colors.fakeLight
                antialiasing: true
            }

            MouseArea {
                id: modeSwitchArea
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    window.darkMode = !window.darkMode
                }
            }
        }

    }
}






/*##^##
Designer {
    D{i:1;anchors_height:200;anchors_width:200;anchors_x:50;anchors_y:55}D{i:3;anchors_height:200;anchors_width:200;anchors_x:44;anchors_y:55}
D{i:5;anchors_x:99;anchors_y:54}D{i:6;anchors_x:99;anchors_y:54}D{i:7;anchors_x:104;invisible:true}
D{i:8;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0;invisible:true}
D{i:9;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}D{i:18;anchors_width:200;anchors_x:99;anchors_y:54}
D{i:16;anchors_height:40;anchors_x:99;anchors_y:54;invisible:true}D{i:21;anchors_x:99;anchors_y:54}
D{i:22;anchors_x:99;anchors_y:54}D{i:20;anchors_x:99;anchors_y:54}D{i:24;anchors_x:245;anchors_y:245}
D{i:25;anchors_x:99;anchors_y:54;invisible:true}D{i:27;anchors_x:99;anchors_y:54;invisible:true}
D{i:28;anchors_x:99;anchors_y:54;invisible:true}D{i:26;anchors_x:99;anchors_y:54;invisible:true}
D{i:19;anchors_width:200;anchors_x:99;anchors_y:54}D{i:15;anchors_width:200;invisible:true}
D{i:31;invisible:true}D{i:32;anchors_x:99;anchors_y:54;invisible:true}D{i:33;anchors_height:22}
D{i:37;anchors_x:99;anchors_y:54;invisible:true}D{i:29;anchors_x:99;anchors_y:54}
D{i:39;anchors_x:99;anchors_y:54;invisible:true}D{i:40;anchors_x:99;anchors_y:54;invisible:true}
D{i:41;anchors_x:99;anchors_y:54;invisible:true}D{i:38;anchors_x:99;anchors_y:54;invisible:true}
D{i:43;anchors_x:99;anchors_y:54;invisible:true}D{i:45;anchors_x:99;anchors_y:54;invisible:true}
D{i:46;invisible:true}D{i:47;invisible:true}D{i:48;invisible:true}D{i:49;invisible:true}
D{i:44;anchors_x:99;anchors_y:54;invisible:true}D{i:42;anchors_x:99;anchors_y:54;invisible:true}
}
##^##*/

