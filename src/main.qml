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

        antialiasing: true

        property color staticDialColor: "#C9C9C9"
        property color pomoDialColor: "red"

        property string text: "Text"
        property real minutes: 25

        signal clicked()

        onMinutesChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.save();

            ctx.clearRect(0, 0, canvas.width, canvas.height);

            const centreX = width / 2;
            const centreY = height / 2;

            ctx.beginPath();
            ctx.lineWidth = 4;
            ctx.strokeStyle = staticDialColor;
            ctx.arc(centreX, centreY, width / 2 - 17, 0 * Math.PI,  2 * Math.PI);
            ctx.stroke();

            ctx.beginPath();
            ctx.lineWidth = 10;
            ctx.strokeStyle = pomoDialColor;
            ctx.arc(centreX, centreY, width / 2 - ctx.lineWidth, 1.5 * Math.PI,  minutes * 6 * Math.PI / 180 + 1.5 * Math.PI);
            ctx.stroke();

       }

        TextInput {
            id: textInput
            width: 80
            height: 34
            text: canvas.minutes
            cursorVisible: false
            anchors.horizontalCenter: canvas.horizontalCenter
            anchors.verticalCenter: canvas.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 36

            onTextChanged: canvas.minutes = textInput.text
        }
    }
}

