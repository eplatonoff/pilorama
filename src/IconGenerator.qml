import QtQuick 2.0

Canvas {
    id: pixmap
    width: 64
    height: 64
    visible: false

    property real runningTime: 0
    property real dialTime: 0

    renderStrategy: Canvas.Threaded;
    renderTarget: Canvas.Image;

    property real centreX : height / 2
    property real centreY : height / 2

    onDialTimeChanged: { requestPaint() }

    onPaint: {
        var trx = getContext("2d");
        trx.save();
        trx.clearRect(0, 0, width, height);

        function iconDial(diameter, stroke, color, startSec, endSec) {
            trx.beginPath();
            trx.lineWidth = stroke;
            trx.strokeStyle = color;
            trx.arc(centreX, centreY, (diameter - stroke) / 2  , startSec / 10 * Math.PI / 180 + 1.5 *Math.PI,  endSec / 10 * Math.PI / 180 + 1.5 *Math.PI);
            trx.stroke();
        }

        trx.font = "32px Arial";
        trx.fillStyle = colors.getColor('dark');
        trx.textAlign = "center";
        trx.fillText(dialTime, centreX, centreY + 10);


        iconDial(width, 8, colors.getColor('light'), 0, 3600 )
        iconDial(width, 8, colors.getColor('yellow'), 0, dialTime )

    }

    onPainted: { tray.pixmap = toDataURL('image/png') }
}
