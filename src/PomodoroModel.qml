import QtQuick 2.0


ListModel {

    property QtObject durationSettings: null

    property int totalPomodoros: 0
    property bool infiniteMode: false

    Component.onCompleted: {
        if (infiniteMode)
            _createBatch();
    }

    onCountChanged: {
        if (infiniteMode && count === 0)
            _createBatch();
    }

    onInfiniteModeChanged: {
        clear();
    }

    function first() {
        return get(0);
    }

    function last() {
        return get(count - 1);
    }

    function removeFirst() {
        if (!first()) {
            throw "first element doesn't exist";
        }

        if (first().type === "pomodoro") {
            totalPomodoros -= 1;
        }
        remove(0);
    }

    function removeLast() {
        if (!last()) {
            throw "last element doesn't exist";
        }

        if (last().type === "pomodoro") {
            totalPomodoros -= 1;
        }
        remove(count - 1);
    }

    function changeQueue(deltaSecs) {

        // change last item duration
        // returns reminded time to assign
        function changeLastItemDuration(secs) {

            if (count === 0)
                return secs;

            const durationBound = _lastItemDurationBound();

            const rawValue = last().duration + secs;

            // item is filled
            if (rawValue > durationBound) {
                last().duration = durationBound;
                return rawValue - durationBound;
            }

            // item is empty
            if (rawValue <= 0) {
                last().duration = 0;
                return rawValue;
            }

            last().duration += secs;
            return 0;
        }

        if (deltaSecs > 0 && count == 0)
            _createNext();

        let secsToCalc = deltaSecs;

        while (secsToCalc !== 0 && count > 0) {

            const restSecs = changeLastItemDuration(secsToCalc);

            if (restSecs < 0)
                removeLast();
            else
            if (restSecs > 0)
                _createNext();

            secsToCalc = restSecs;
        }

        console.log(JSON.stringify(last()));
    }

    function drainTime(secs) {

        if (secs <= 0)
            throw "arg must be positivie";

        if (count === 0)
            return;

        let secsToDrain = secs;

        while(secsToDrain !== 0 && count > 0) {
            first().duration -= secsToDrain;

            if (first().duration <= 0) {
                secsToDrain = Math.abs(first().duration);
                removeFirst();
            }
            else
                secsToDrain = 0;
        }

    }


    function _lastItemDurationBound() {

        if (this.count === 0) {
            throw "pomodoro queue is empty";
        }

        switch (last().type) {
        case "pomodoro":
            return durationSettings.pomodoro;
        case "pause":
            return durationSettings.pause;
        case "break":
            return durationSettings.breakTime;
        default:
            throw "unknown time segment type";
        }
    }

    function _createNext() {

        function createPomodoro() {
            append({"type": "pomodoro", "duration": 0});
            totalPomodoros += 1;
        }

        function createPauseOrBreak() {
            if (totalPomodoros % durationSettings.repeatBeforeBreak === 0 ) {
                append({"type": "break", "duration": 0});
            }
            else
                append({"type": "pause", "duration": 0});
        }

        if (count == 0) {
            createPomodoro();
            return;
        }

        switch (last().type) {
        case "pomodoro": createPauseOrBreak(); break;
        case "pause":
        case "break":
            createPomodoro(); break;
        default:
            throw "unknown time segment type";
        }
    }


    function _createBatch() {
        changeQueue(
            durationSettings.pomodoro * durationSettings.repeatBeforeBreak +
            durationSettings.pause * (durationSettings.repeatBeforeBreak - 1) +
            durationSettings.breakTime
        );
    }

}
