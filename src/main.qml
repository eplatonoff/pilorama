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

        rotation: -90
        antialiasing: true

        property color staticDialColor: "#C9C9C9"
        property color pomoDialColor: "red"

        property string text: "Text"

        property real hours: 0
        property real minutes: 0
        property real seconds: 0

        property real time: 0

        signal clicked()

        onTimeChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.save();

            ctx.clearRect(0, 0, canvas.width, canvas.height);

            const centreX = width / 2;
            const centreY = height / 2;

            function dial(diametr, stroke, color, startSec, endSec) {
                ctx.beginPath();
                ctx.lineWidth = stroke;
                ctx.strokeStyle = color;
                ctx.arc(centreX, centreY, diametr / 2 - stroke, startSec / 10 * Math.PI / 180,  endSec / 10 * Math.PI / 180);
                ctx.stroke();
            }

            dial(width, 4, staticDialColor, 0, canvas.time)
            dial(width - 5, 10, pomoDialColor, 0, canvas.time)

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



