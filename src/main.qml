import QtQuick 2.13
import QtQuick.Window 2.13
import QtGraphicalEffects 1.12
import QtMultimedia 5.13

Window {
    id: window
    visible: true
    width: 300
    height: 300
    color: darkMode ? colors.bgDark : colors.bgLight
    title: qsTr("qml timer")

    property bool darkMode: false
    property bool soundOn: true
    property bool showPrefs: false

    onDarkModeChanged: { canvas.requestPaint()}
    onShowPrefsChanged: { canvas.requestPaint()}

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
    Item {
//        id: globalTimer
//        property bool running: true
//        property real duration: 25
//        property real timeLeft: 0

        Timer {
            id: globalTimer
            property real duration: 0

            onDurationChanged: {canvas.requestPaint()}

            interval: 1000;
            running: false;
            repeat: true
            onTriggered: {
                duration >= 1 ? duration = duration - 1 : stop()
                canvas.requestPaint()
                console.log(duration)
            }
        }
    }
    Item {
        id: fakeDial
        property color color: colors.fakeLight
    }
    Item {
        id: timerDial

        property color color: colors.accentLight

        property real angle: globalTimer.duration / 10

        property bool bell: true
        property bool endSoon: true

        property real endSoonTime: 5


    }
    Item {
        id: pomodoro

        property color color: colors.pomodoroLight

        property bool fullCircle: true

        property real duration: 25
        property real timeshift: 0

        property bool bell: true
        property bool endSoon: true

        property real endSoonTime: 5

    }
    Item {
        id: shortBreak

        property color color: colors.shortBreakLight

        property bool fullCircle: true

        property real duration: 10
        property real timeshift: 0

        property bool bell: true
        property bool endSoon: true

        property real endSoonTime: 5
    }
    Item {
        id: longBreak

        property color color: colors.longBreakLight

        property bool fullCircle: true

        property real duration: 15
        property real timeshift: 0

        property bool bell: true
        property bool endSoon: true

        property real endSoonTime: 5
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

                property real time: 0
                property string timeMin: "00"
                property string timeSec: "00"

                property real dialAbsolute: 0

                property real sectorPomoVisible: 0

                property string text: "Text"

                signal clicked()

                property real centreX : width / 2
                property real centreY : height / 2

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.save();

                    ctx.clearRect(0, 0, canvas.width, canvas.height);


                    function dial(diametr, stroke, dashed, color, startSec, endSec) {
                        ctx.beginPath();
                        ctx.lineWidth = stroke;
                        ctx.strokeStyle = color;
                        if (dashed) {

                            var clength = Math.PI * (diametr - stroke) / 10;
                            var devisions = 180;
                            var dash = clength / devisions / 5;
                            var space = clength / devisions - dash;

                            ctx.setLineDash([dash, space]);

                        } else {
                            ctx.setLineDash([1,0]);
                        }

                        ctx.arc(centreX, centreY, diametr / 2 - stroke, startSec * Math.PI / 180 + 1.5 *Math.PI,  endSec * Math.PI / 180 + 1.5 *Math.PI);
                        ctx.stroke();
                    }

                    dial(width - 7, 12, true, window.darkMode ? colors.fakeDark : colors.fakeLight, 0, 3600)
                    dial(width, 4, false, window.darkMode ? colors.accentDark : colors.accentLight, 0, timerDial.angle)

                    timerDial.angle <= pomodoro.duration * 6 ? canvas.sectorPomoVisible = 0 : canvas.sectorPomoVisible = timerDial.angle - pomodoro.duration * 6

                    dial(width - 7, 12, false, window.darkMode ? colors.pomodoroDark : colors.pomodoroLight, canvas.sectorPomoVisible, timerDial.angle)

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

                    property point circleStart: Qt.point(0, 0)
                    property point mousePoint: Qt.point(0, 0)
                    property real scroll: 0
                    property real scrollMultiplier: 5

                    onReleased: {
                        globalTimer.duration > 0 ? globalTimer.start() : globalTimer.stop()
                        console.log("triggered")
                    }

                    onPositionChanged: {
                        globalTimer.stop()
                        function mouseAngle(refPointX, refPointY){
                            const {x, y} = mouse;
                            mousePoint = Qt.point(x, y);
                            const radius = Math.hypot(x - refPointX, y - refPointY);

                            circleStart = Qt.point(refPointX, refPointY - radius)
                            const horde = Math.hypot(x - refPointX, y - (refPointY - radius));
                            const angle = Math.asin((horde/2) / radius ) * 2 * ( 180 / Math.PI );

                            if (mousePoint.x >= circleStart.x) {
                                return angle
                            } else {
                                return 360 - angle
                            }
                        }

                        globalTimer.duration = Math.trunc(mouseAngle(canvas.centreX, canvas.centreY) * 10)
                    }

                }

            }

            Item {
                id: digitalClock
                x: 20
                y: 9
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

                Text {
                    id: digitalSec
                    height: 22
                    text: parent.pad(globalTimer.duration % 60)
                    verticalAlignment: Text.AlignTop
                    anchors.top: digitalMin.top
                    anchors.topMargin: 0
                    anchors.left: digitalMin.right
                    anchors.leftMargin: 3
                    font.pixelSize: 22
                    color: darkMode ? colors.accentTextDark : colors.accentTextLight
                }

                TextInput {
                    id: digitalMin
                    y: 112
                    width: 60
                    height: 44
                    text: parent.pad(Math.trunc(globalTimer.duration / 60))
                    anchors.left: parent.left
                    anchors.leftMargin: 26
                    font.preferShaping: true
                    font.kerning: true
                    renderType: Text.QtRendering
                    font.underline: false
                    font.italic: false
                    font.bold: false
                    color: darkMode ? colors.accentTextDark : colors.accentTextLight
                    anchors.verticalCenterOffset: 0
                    cursorVisible: false
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: 44
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

                property bool playSound: globalTimer.duration

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                onSoundOnChanged: {
                    if ( soundOn ){
                        soundIcon.source = iconSound
                        soundNotification.muted = false
                    } else{
                        soundIcon.source = iconNoSound
                        soundNotification.muted = true
                    }

                }

                onPlaySoundChanged: {
                    !playSound ? soundNotification.play() : soundNotification.stop()
                }

                ColorOverlay{
                    id: soundIconOverlay
                    anchors.fill: parent
                    source: parent
                    color: window.darkMode ? colors.fakeDark : colors.fakeLight
                    antialiasing: true
                }

                SoundEffect {
                    id: soundNotification
                    muted: false
                    source: "./sound/danay.wav"
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
D{i:6;anchors_x:99;anchors_y:54}D{i:9;anchors_height:200;anchors_width:200;anchors_x:0;anchors_y:0}
D{i:15;anchors_width:200;invisible:true}D{i:16;anchors_x:99;anchors_y:54;invisible:true}
D{i:8;invisible:true}D{i:18;anchors_width:200;anchors_x:99;anchors_y:54}D{i:20;anchors_x:99;anchors_y:54}
D{i:21;anchors_x:99;anchors_y:54}D{i:22;anchors_x:99;anchors_y:54}D{i:24;anchors_x:245;anchors_y:245}
D{i:26;anchors_x:99;anchors_y:54;invisible:true}D{i:27;invisible:true}D{i:25;anchors_x:99;anchors_y:54;invisible:true}
D{i:19;anchors_width:200;anchors_x:99;anchors_y:54}D{i:29;anchors_x:99;anchors_y:54;invisible:true}
D{i:30;invisible:true}D{i:28;anchors_x:99;anchors_y:54;invisible:true}D{i:32;invisible:true}
D{i:33;invisible:true}D{i:31;invisible:true}D{i:7;anchors_x:104}
}
##^##*/
