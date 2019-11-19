import QtQuick 2.0

ListModel {

    property string data: ''

    Component.onCompleted: load()
    Component.onDestruction: save()


// Adds item to sequence

    function add(name, color, duration){
        const defaultName = "Split " + count
        const defaultColor = randomColor()
        const defaultSetting = 25 * 60

        const n = name ?  name : defaultName
        const c = color ? color : defaultColor
        const s = duration ? duration : defaultSetting
        append({"name": n, "color": c, "setting": s, "duration": s})
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
}




