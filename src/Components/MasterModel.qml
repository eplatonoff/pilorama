import QtQuick

ListModel {

    id: masterModel

    property string title: 'Sequence'
    property string data: ''
    property string defaultName: 'Split'
    property string defaultColor: randomColor()
    property real defaultDuration: 15

    Component.onCompleted: load()
    Component.onDestruction: save()

    property var demo: '[
        {"id":0,"name":"Pomodoro","color":"red","duration":1500},
        {"id":1,"name":"Short Break","color":"green","duration":300},
        {"id":2,"name":"Pomodoro","color":"red","duration":1500},
        {"id":3,"name":"Short Break","color":"green","duration":300},
        {"id":4,"name":"Pomodoro","color":"red","duration":1500},
        {"id":5,"name":"Short Break","color":"green","duration":300},
        {"id":6,"name":"Pomodoro","color":"red","duration":1500},
        {"id":7,"name":"Long Break","color":"blue","duration":900}
    ]'


// Adds item to sequence

    function add(name, color, duration){
        const n = name  ?  name : defaultName + " " + (count + 1)
        const c = color ? color : defaultColor
        const d = duration !== undefined ? duration : defaultDuration * 60
        append({"id": count, "name": n, "color": c, "duration": d})
        recalcIDs()
    }

    function recalcIDs(){
        for (var i = 0; i < count; i++){
            get(i).id = i
        }
    }

// Random color without repeats

    function randomColor(){
        const col = colors.list()
        var cl = col.length
        var colMod = []
        var remained

        if (count < cl && count > 0){
            for(var i=0; i<count; i++) colMod.push(this.get(i).color)
            remained = col.filter(c => !colMod.includes(c))
        }

        else {
            var color = count > 0 ? this.get(count-1).color : col[cl - 1]
            remained = col.filter(c => c !== color)
        }

        var rand = Math.floor(Math.random() * remained.length)

        return remained[rand]

    }

// Saves sequence to setting

    function save(){
        recalcIDs()
        var datamodel = []
        for (var i = 0; i < count; ++i) datamodel.push(get(i))
        data = JSON.stringify(datamodel)
    }

// Loads sequence from setting

    function load(){
        clear()

        let datamodel;

        try {
            datamodel = JSON.parse(data);

            if (datamodel.length < 1) {
                datamodel = JSON.parse(demo);
            }
        }
        catch(err) {
            datamodel = JSON.parse(demo);
        }

        for (var i = 0; i < datamodel.length; ++i) {
            append(datamodel[i])
        }
    }


    function totalDuration(){
        let duration = 0
        for(var i = 0; i<count; i++){
           duration += get(i).duration
        }
        return duration
    }

    function showModel(){
        var datamodel = []
        for (var i = 0; i < count; ++i) datamodel.push(get(i))
        console.log("MASTER:", JSON.stringify(datamodel), "Total items: " + count)
    }
}




