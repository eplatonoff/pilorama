import QtQuick 2.13
import QtQuick.Window 2.13

Window {
    id: window
    visible: true
    width: 300
    height: 300
    color: "white"
    title: qsTr("qml timer")

    property bool darkMode: true

    property color bgDay: "white"
    property color bgNight: "#282828"

    onDarkModeChanged: {
        if (darkMode){
            window.color = window.bgDay
            bigClock.color = "black"
            fakeDial.color = fakeDial.colorDay
            modeSwitch.source = modeSwitch.iconNight
            timerDial.color = timerDial.colorDay
            pomodoroDial.color = pomodoroDial.colorDay

            canvas.requestPaint()
        }else{
            window.color = window.bgNight
            bigClock.color = "white"
            fakeDial.color = fakeDial.colorNight
            modeSwitch.source = modeSwitch.iconDay
            timerDial.color = timerDial.colorNight
            pomodoroDial.color = pomodoroDial.colorNight

            canvas.requestPaint()
        }
    }

    Canvas {

        id: canvas

        anchors.rightMargin: 20
        anchors.leftMargin: 20
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottomMargin: 20
        anchors.topMargin: 20

        antialiasing: true

        property real time: 0

        property real dialAbsolute: 0

        property real sectorPomo: 1500
        property real sectorPomoVisible: 0

        property string text: "Text"


        signal clicked()

        property real centreX : width / 2
        property real centreY : height / 2

        onTimeChanged: requestPaint()

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
                    var dash = clength / devisions / 3;
                    var space = clength / devisions - dash;

                    console.log(diametr, clength, dash, space);

                    ctx.setLineDash([dash, space]);

                } else {
                    ctx.setLineDash([1,0]);
                }

                ctx.arc(centreX, centreY, diametr / 2 - stroke, startSec / 10 * Math.PI / 180 + 1.5 *Math.PI,  endSec / 10 * Math.PI / 180 + 1.5 *Math.PI);
                ctx.stroke();
            }

            dial(width - 7, 12, true ,fakeDial.color, 0, 3600)
            dial(width, 4, false ,timerDial.color, 0, canvas.time)

            canvas.time <= canvas.sectorPomo ? canvas.sectorPomoVisible = 0 : canvas.sectorPomoVisible = canvas.time - canvas.sectorPomo

            dial(width - 7, 12, false ,pomodoroDial.color, canvas.sectorPomoVisible, canvas.time)

            //            ctx.fillStyle = "black";

            //            ctx.ellipse(mouseArea.circleStart.x, mouseArea.circleStart.y, 5, 5);
            //            ctx.fill();

            //            ctx.beginPath();
            //            ctx.lineWidth = 2;
            //            ctx.strokeStyle = "black";
            //            ctx.moveTo(mouseArea.circleStart.x, mouseArea.circleStart.y);
            //            ctx.lineTo(mouseArea.mousePoint.x, mouseArea.mousePoint.y);
            //            ctx.lineTo(centreX, centreY);
            //            ctx.lineTo(mouseArea.circleStart.x, mouseArea.circleStart.y);
            //            ctx.stroke();
        }


        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            propagateComposedEvents: true

            property point circleStart: Qt.point(0, 0)
            property point mousePoint: Qt.point(0, 0)

            onPositionChanged: {
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
                        return 180 - angle + 180
                    }
                }

//                console.log(mouseAngle(canvas.centreX, canvas.centreY));
                canvas.time = Math.trunc(mouseAngle(canvas.centreX, canvas.centreY) * 10)

                //                parent.requestPaint();

            }

        }

    }
    TextInput {
        id: bigClock
        width: 46
        height: 34
        text: canvas.time
        color: "black"
        anchors.verticalCenterOffset: 0
        anchors.horizontalCenterOffset: 0
        cursorVisible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 30

        onTextChanged: canvas.time = bigClock.text
    }


    Image {
        id: modeSwitch
        x: 28
        y: 28
        width: 24
        height: 24
        sourceSize.width: 24
        sourceSize.height: 24
        antialiasing: true
        smooth: true
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        fillMode: Image.PreserveAspectFit
        source: "./img/moon.png"

        property string iconDay: "./img/sun.png"
        property string iconNight: "./img/moon.png"

        MouseArea {
            id: modeSwitchArea
            hoverEnabled: true
            anchors.fill: parent
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor

            onReleased: {
                window.darkMode = !window.darkMode
            }
        }
    }

    Item {
        id: fakeDial

        property color color: "#EEEDE9"

        property color colorDay: "#EEEDE9"
        property color colorNight: "#323635"

    }

    Item {
        id: timerDial

        property color color: "#968F7E"

        property color colorDay: "#968F7E"
        property color colorNight: "#859391"

        property real duration: 25

        property bool bell: true
        property bool endSoon: true

        property real endSoonTime: 5


    }

    Item {
        id: pomodoroDial

        property color color: "#E26767"

        property color colorDay: "#E26767"
        property color colorNight: "#C23E3E"

        property bool fullCircle: true

        property real duration: 25
        property real timeshift: 0

        property bool bell: true
        property bool endSoon: true

        property real endSoonTime: 5

    }
    Item {
        id: shortBreakDial

        property color color: "#7DCF6F"

        property color colorDay: "#7DCF6F"
        property color colorNight: "#5BB44C"

        property bool fullCircle: true

        property real duration: 10
        property real timeshift: 0

        property bool bell: true
        property bool endSoon: true

        property real endSoonTime: 5
    }
    Item {
        id: longBreakDial

        property color color: "#67C5D1"

        property color colorDay: "#67C5D1"
        property color colorNight: "#4E919A"

        property bool fullCircle: true

        property real duration: 15
        property real timeshift: 0

        property bool bell: true
        property bool endSoon: true

        property real endSoonTime: 5
    }


}



