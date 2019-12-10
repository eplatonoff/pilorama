import QtQuick 2.0

ListModel {

    id: masterModel

    property string title: 'Sequence'
    property string data: ''
    property string defaultName: 'Split'
    property string defaultColor: randomColor()
    property real defaultDuration: 15

    Component.onCompleted: load()
    Component.onDestruction: save()

    property var demo: '[{"id":0,"name":"Demo","color":"red","duration":900}]'


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
        if(data === "[]"){ data = demo; }
        const datamodel = JSON.parse(data)
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




