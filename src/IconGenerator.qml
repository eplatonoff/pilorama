import QtQuick 2.0

Canvas {
    id: pixmap
    width: 32
    height: 32
    visible: false

    property real runningTime: 0

    renderStrategy: Canvas.Threaded;
    renderTarget: Canvas.Image;

    property real centreX : 32 / 2
    property real centreY : 32 / 2

    property var data


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

        function dialTime(){
            return pomodoroQueue.first().duration * 3600 / masterModel.get(pomodoroQueue.first().id).duration
        }

        iconDial(32, 6, colors.getColor("mid gray"), 0, 3600 )
        if(pomodoroQueue.infiniteMode){
            iconDial(32, 6, colors.getColor(masterModel.get(pomodoroQueue.first().id).color), 0, dialTime() )
        }

//        var url = toDataURL('image/png')
//        tray.iconSource = url

    }

    onPainted: {
//        tray.pixmap = './assets/tray/static.svg'
        pixmap.data = toDataURL('image/png')
    }

}
