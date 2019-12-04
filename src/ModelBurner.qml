import QtQuick 2.0


ListModel {

    id: pomodoroQueue

    property QtObject durationSettings: null

    property int totalPomodoros: 0
    property bool infiniteMode: false

    Component.onCompleted: {
        _tryToCreateBatch();
    }

    onCountChanged: {

        if (count === 0)
            totalPomodoros = 0;

        _tryToCreateBatch();
    }

    onInfiniteModeChanged: {
        clear();
        _tryToCreateBatch();

    }

    function _tryToCreateBatch() {
        if (infiniteMode && count === 0) {
            _createBatch();
        }
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
        remove(0);
    }

    function removeLast() {
        if (!last()) {
            throw "last element doesn't exist";
        }
        remove(count - 1);
    }

    function restoreDuration(index) {
        const item = get(index);

        if (!item)
            throw "Item doesn't exists";

        item.duration = itemDurationBound(item);
    }

    function changeQueue(deltaSecs) {

        // change last item duration
        // returns reminded time to assign
        function changeLastItemDuration(secs) {

            if (count == 0) { return secs; }

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

        if (count === 0) {
            throw "pomodoro queue is empty";
        }

        return itemDurationBound(last());
    }

    function itemDurationBound(item) {
        return masterModel.get(item.id).duration
    }

    function _createNext()
    {
        const masterCount = masterModel.count;

        if (masterCount === 0)
            throw "master model is empty";

        const masterId = count >= masterCount ? count % masterCount : count;

        append({"id": masterId,  "duration": 0})
    }

    function _createBatch() {
        changeQueue( masterModel.totalDuration() );
    }

    function showQueue(){
        var datamodel = []
        for (var i = 0; i < count; ++i) datamodel.push(get(i))
        console.log(JSON.stringify(datamodel), "Total items: " + count)
    }

}
