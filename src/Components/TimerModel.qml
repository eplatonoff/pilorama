import QtQuick

ListModel {
    id: timerModel

    property string data: ''
    property string defaultColor: "red"
    property real defaultDuration: 15
    property string defaultName: 'Split'
    property var pomodoro: [
        {
            "id": 0,
            "name": "Pomodoro",
            "color": "red",
            "duration": 1500
        },
        {
            "id": 1,
            "name": "Short Break",
            "color": "green",
            "duration": 300
        },
        {
            "id": 2,
            "name": "Pomodoro",
            "color": "red",
            "duration": 1500
        },
        {
            "id": 3,
            "name": "Short Break",
            "color": "green",
            "duration": 300
        },
        {
            "id": 4,
            "name": "Pomodoro",
            "color": "red",
            "duration": 1500
        },
        {
            "id": 5,
            "name": "Short Break",
            "color": "green",
            "duration": 300
        },
        {
            "id": 6,
            "name": "Pomodoro",
            "color": "red",
            "duration": 1500
        },
        {
            "id": 7,
            "name": "Long Break",
            "color": "blue",
            "duration": 900
        },
    ]
    property string title: 'Pomodoro'

    function add(name, color, duration) {
        const n = name ? name : defaultName + " " + (count + 1);
        const c = color ? color : defaultColor;
        const d = duration !== undefined ? duration : defaultDuration * 60;
        append({
            "id": count,
            "name": n,
            "color": c,
            "duration": d
        });
        reIndex();
    }
    function load() {
        clear();
        let datamodel = [];
        try {
            datamodel = JSON.parse(data);
        } catch (err)
        // Okay, people, move along! Nothing to see here, you lookie loos!
        {}
        if (datamodel.length < 1) {
            datamodel = pomodoro;
        }
        for (let i = 0; i < datamodel.length; ++i) {
            timerModel.append(datamodel[i]);
        }
    }
    function reIndex() {
        for (var i = 0; i < count; i++) {
            get(i).id = i;
        }
    }
    function save() {
        reIndex();
        var datamodel = [];
        for (var i = 0; i < count; ++i)
            datamodel.push(get(i));
        data = JSON.stringify(datamodel);
    }
    function totalDuration() {
        let duration = 0;
        for (let i = 0; i < count; i++) {
            duration += timerModel.get(i).duration;
        }
        return duration;
    }

    Component.onCompleted: timerModel.load()
    Component.onDestruction: timerModel.save()
}
