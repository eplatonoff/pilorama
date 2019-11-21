import QtQuick 2.0

ListModel {

    id: masterModel

    property string data: ''
    property string defaultName: 'Split'
    property string defaultColor: randomColor()
    property real defaultDuration: 25

    Component.onCompleted: load()
    Component.onDestruction: save()



// Adds item to sequence

    function add(id, name, color, duration){
        const i = id ?  id : index
        const n = name ?  name : defaultName + " " + (count + 1)
        const c = color ? color : defaultColor
        const d = duration ? duration : defaultDuration * 60
        append({"id": i,"name": n, "color": c, "duration": d})
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
        var datamodel = []
        for (var i = 0; i < count; ++i) datamodel.push(get(i))
        data = JSON.stringify(datamodel)
    }

// Loads sequence from setting

    function load(){
        if (data) {
          clear()
          var datamodel = JSON.parse(data)
          for (var i = 0; i < datamodel.length; ++i) {
              append(datamodel[i])
          }
        }
    }


    function totalDuration(){
        let duration = 0
        for(var i = 0; i<count; i++){
           duration += get(i).duration
        }
        return duration
    }

    function getSeqId(seqId){
        if( count == 0) { throw "no items in master" }
        const id = seqId >= count ? seqId % count : seqId
        return get(id)
    }

    function showModel(){
        var datamodel = []
        for (var i = 0; i < count; ++i) datamodel.push(get(i))
        console.log("MASTER:", JSON.stringify(datamodel), "Total items: " + count)
    }
}




