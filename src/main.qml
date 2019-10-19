import QtQuick 2.13
import QtQuick.Window 2.13

Window {
    id: window
    visible: true
    width: 300
    height: 300
    color: "#EFEEE9"
    title: qsTr("qml timer")

    property bool darkMode: true

    property color bgDay: "#EFEEE9"
    property color bgNight: "#282828"

    onDarkModeChanged: {
        if (darkMode){
            window.color = window.bgDay
            digitalMin.color = "black"
            fakeDial.color = fakeDial.colorDay
            modeSwitch.source = modeSwitch.iconNight
            timerDial.color = timerDial.colorDay
            pomodoroDial.color = pomodoroDial.colorDay

            canvas.requestPaint()
        } else {
            window.color = window.bgNight
            digitalMin.color = "white"
            fakeDial.color = fakeDial.colorNight
            modeSwitch.source = modeSwitch.iconDay
            timerDial.color = timerDial.colorNight
            pomodoroDial.color = pomodoroDial.colorNight

            canvas.requestPaint()
        }
    }

    Rectangle {
        id: content
        color: "transparent"
        anchors.rightMargin: 16
        anchors.leftMargin: 16
        anchors.bottomMargin: 16
        anchors.topMargin: 16
        anchors.fill: parent

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

            property real sectorPomo: 1500
            property real sectorPomoVisible: 0

            property string text: "Text"


            signal clicked()

            property real centreX : width / 2
            property real centreY : height / 2

            function pad(value){
                if (value < 10) {return "0" + value
                } else {return value}
            }

            onTimeChanged: {
                canvas.timeMin = pad(Math.trunc(canvas.time / 60))
                canvas.timeSec = pad(canvas.time - Math.trunc(canvas.time / 60) * 60)
                requestPaint()
            }

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

        Image {
            id: modeSwitch
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            sourceSize.width: 23
            sourceSize.height: 23
            antialiasing: true
            smooth: true
            fillMode: Image.PreserveAspectFit
            source: "./img/moon.svg"

            property string iconDay: "./img/sun.svg"
            property string iconNight: "./img/moon.svg"
            width: 24

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

        Item {
            id: digitalClock
            width: 140
            height: 140
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: digitalSec
                height: 22
                text: canvas.timeSec
                verticalAlignment: Text.AlignTop
                anchors.top: digitalMin.top
                anchors.topMargin: 0
                anchors.left: digitalMin.right
                anchors.leftMargin: 3
                font.pixelSize: 22
                color: digitalMin.color
            }

            TextInput {
                id: digitalMin
                y: 112
                width: 60
                height: 44
                text: canvas.timeMin
                anchors.left: parent.left
                anchors.leftMargin: 26
                font.preferShaping: true
                font.kerning: true
                renderType: Text.QtRendering
                font.underline: false
                font.italic: false
                font.bold: false
                color: "black"
                anchors.verticalCenterOffset: 0
                cursorVisible: false
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                font.pixelSize: 44
            }
        }

        Image {
            id: sound
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            sourceSize.height: 23
            sourceSize.width: 23
            source: "./img/sound.svg"
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: prefs
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            source: "./img/prefs.svg"
            fillMode: Image.PreserveAspectFit
        }
    }


    Item {
        id: fakeDial

        property color color: "#CEC9B6"

        property color colorDay: "#CEC9B6"
        property color colorNight: "#4F5655"

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

        property color color: "#6F85CF"

        property color colorDay: "#6F85CF"
        property color colorNight: "#5069BE"

        property bool fullCircle: true

        property real duration: 15
        property real timeshift: 0

        property bool bell: true
        property bool endSoon: true

        property real endSoonTime: 5
    }



}




/*##^##
Designer {
    D{i:7;anchors_x:99;anchors_y:54}D{i:8;anchors_x:104}D{i:1;anchors_height:200;anchors_width:200;anchors_x:50;anchors_y:55}
}
##^##*/
