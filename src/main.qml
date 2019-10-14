import QtQuick 2.13
import QtQuick.Window 2.13

Window {
    id: window
    visible: true
    width: 300
    height: 300
    color: "#f1f1f1"
    title: qsTr("qml timer")



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

//        rotation: -90
        antialiasing: true

        property color staticDialColor: "#C9C9C9"
        property color pomoDialColor: "red"

        property string text: "Text"

        property real hours: 0
        property real minutes: 0
        property real seconds: 0

        property real time: 0

        signal clicked()

        property real centreX : width / 2
        property real centreY : height / 2

        onTimeChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.save();

            ctx.clearRect(0, 0, canvas.width, canvas.height);


            function dial(diametr, stroke, color, startSec, endSec) {
                ctx.beginPath();
                ctx.lineWidth = stroke;
                ctx.strokeStyle = color;
                ctx.arc(centreX, centreY, diametr / 2 - stroke, startSec / 10 * Math.PI / 180,  endSec / 10 * Math.PI / 180);
                ctx.stroke();
            }

            dial(width, 4, staticDialColor, 0, canvas.time)
            dial(width - 5, 10, pomoDialColor, 0, canvas.time)

            ctx.fillStyle = "black";

            ctx.ellipse(mouseArea.circleStart.x, mouseArea.circleStart.y, 5, 5);
            ctx.fill();

            ctx.beginPath();
            ctx.lineWidth = 2;
            ctx.strokeStyle = "black";
            ctx.moveTo(mouseArea.circleStart.x, mouseArea.circleStart.y);
            ctx.lineTo(mouseArea.mousePoint.x, mouseArea.mousePoint.y);
            ctx.lineTo(centreX, centreY);
            ctx.lineTo(mouseArea.circleStart.x, mouseArea.circleStart.y);
            ctx.stroke();
       }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            id: mouseArea
            property point circleStart: Qt.point(0, 0)
            property point mousePoint: Qt.point(0, 0)

            onPositionChanged: {
                const {x, y} = mouse;

                mousePoint = Qt.point(x, y);

                const radius = Math.hypot(x - parent.centreX, y - parent.centreY);

                const circleStartY = parent.centreY - radius;
                const circleStartX = parent.centreX;

                circleStart = Qt.point(circleStartX, circleStartY)

                const horde = Math.hypot(x - circleStartX, y - circleStartY);

                const angle = Math.asin((horde/2) / radius ) * 2 * ( 180 / Math.PI );
                console.log(angle);

                parent.requestPaint();

            }
        }




    }


    TextInput {
        id: sec
        width: 46
        height: 34
        text: canvas.seconds
        anchors.verticalCenterOffset: 0
        anchors.horizontalCenterOffset: 0
        cursorVisible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 36

        onTextChanged: canvas.time = sec.text
    }

}



