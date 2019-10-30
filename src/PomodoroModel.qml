import QtQuick 2.0


ListModel {

    property QtObject durationSettings: null

    property int totalPomodoros: 0

    function topItemDurationBound() {

        if (this.count === 0) {
            throw "pomodoro queue is empty";
        }

        switch (get(0).type) {
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

    function top() {
        return get(0);
    }

    function removeTop() {
        if (top().type === "pomodoro") {
            totalPomodoros -= 1;
        }
        remove(0);
    }

    function createTop() {

        function insertPomodoro() {
            insert(0, {"type": "pomodoro", "duration": 0});
            totalPomodoros += 1;
        }

        function insertPauseOrBreak() {
            if (totalPomodoros % durationSettings.repeatBeforeBreak === 0 ) {
                insert(0, {"type": "break", "duration": 0});
            }
            else
                insert(0, {"type": "pause", "duration": 0});
        }

        if (count == 0) {
            insertPomodoro();
            return;
        }

        switch (top().type) {
        case "pomodoro": insertPauseOrBreak(); break;
        case "pause":
        case "break":
            insertPomodoro(); break;
        default:
            throw "unknown time segment type";
        }
    }

    function changeQueue(deltaSecs) {

        // change top item duration
        // returns reminded time to assign
        function changeItem(secs) {

            if (count === 0)
                return secs;

            const durationBound = topItemDurationBound();

            const rawValue = top().duration + secs;

            // item is filled
            if (rawValue > durationBound) {
                top().duration = durationBound;
                return rawValue - durationBound;
            }

            // item is empty
            if (rawValue <= 0) {
                top().duration = 0;
                return rawValue;
            }

            top().duration += secs;
            return 0;
        }

        let secsToCalc = deltaSecs;

        while (secsToCalc !== 0) {

            const restSecs = changeItem(secsToCalc);

            if (restSecs < 0) {

                if (count === 0)
                    break;

                removeTop();
            }
            else
            if (restSecs > 0) {
                createTop();
            }

            secsToCalc = restSecs;
        }

        console.log(JSON.stringify(get(0)));
    }
}
