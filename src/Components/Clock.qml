import QtQuick

Item {
    id: clock

    property var timerRef
    property string currentTime: ''
    property string notificationTime: ''

    property real duration: timerRef ? timerRef.remainingTime : 0
    property real splitDuration: timerRef ? timerRef.segmentRemainingTime : 0

    onDurationChanged: clock.resetClock()
    onSplitDurationChanged: clock.resetClock()

    Timer {
        id: pauseClockUpdater
        interval: 60000
        repeat: true
        triggeredOnStart: true
        onTriggered: clock.resetClock()
        running: clock.timerRef && !clock.timerRef.running && clock.getDuration()
    }

    function pad(value){
        if (value < 10) {return "0" + value
        } else {return value}
    }

    function getDuration(){
        if (!timerRef || !timerRef.splitMode) {
            return duration
        }
        if (timerRef.running && splitDuration > 0) {
            return splitDuration
        }
        return duration
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

    function getTimeAfter(secs) {
        let _t = getTime().h * 3600 + getTime().min * 60 + getTime().sec
        let t = _t + secs

        t = t >= 86400 ? t % 86400 : t

        let h = Math.floor(t / 3600)
        let m = Math.floor(t / 60) - h * 60
        let s = t - (h * 3600 + m * 60)

        let resulting = pad(h) + ":" + pad(m)

        return {'h': h, 'min': m, 'sec': s, 'clock': resulting}
    }

    function resetClock(){
        currentTime = getTime().clock
        notificationTime = getNotificationTime().clock
    }

}
