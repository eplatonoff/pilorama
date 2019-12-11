import QtQuick 2.0

Item {
    id: clock

    property string currentTime: ''
    property string notificationTime: ''

    property real duration: globalTimer.duration
    property real splitDuration: globalTimer.splitDuration

    onDurationChanged: resetClock()
    onSplitDurationChanged: resetClock()

    function pad(value){
        if (value < 10) {return "0" + value
        } else {return value}
    }

    function getDuration(){
        if(!pomodoroQueue.infiniteMode){
          return duration
        } else {
          return splitDuration ?  splitDuration : masterModel.get(0).duration
        }
    }


    function getTime(){
        const today = new Date()
        const h = today.getHours()
        const m = today.getMinutes()
        const s = today.getSeconds()

        const resulting = pad(h) + ":" + pad(m)

        return {'h': h, 'min':m, 'sec':s, 'clock': resulting }
    }

    function getNotificationTime() {

        let _t = getTime().h * 3600 + getTime().min * 60 + getTime().sec
        let t = _t + getDuration()

        t = t >= 86400 ? t % 86400 : t

        let h = Math.floor( t / 3600 )
        let m = Math.floor( t / 60 ) - h * 60
        let s = t - (h * 3600 + m * 60)

        let resulting = pad(h) + ":" + pad(m)

        return {'h': h, 'min': m, 'sec': s, 'clock': resulting}
    }

    function resetClock(){
        currentTime = getTime().clock
        notificationTime = getNotificationTime().clock
    }

}
