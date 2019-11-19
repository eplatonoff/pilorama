import QtQuick 2.0
import Qt.labs.settings 1.0

ListModel {

    Component.onCompleted: load()
    Component.onDestruction: save()

    // Demo list

    ListElement {
        name: "pomodoro"
        color: "red"
        duration: 1500
    }
    ListElement {
        name: "pause"
        color: "green"
        duration: 400
    }
    ListElement {
        name: "pomodoro"
        color: "red"
        duration: 1500
    }
    ListElement {
        name: "break"
        color: "blue"
        duration: 600
    }

    function add(name, color, duration){
        const defaultName = "Split " + count
        const defaultColor = randomColor()
        const defaultDuration = 25 * 60

        const n = name ?  name : defaultName
        const c = color ? color : defaultColor
        const d = duration ? duration : defaultDuration
        append({"name": n, "color": c, "duration": d })
    }

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

    function save(){
        var datamodel = []
        for (var i = 0; i < count; ++i) datamodel.push(get(i))
        sequenceSettings.data = JSON.stringify(datamodel)
        console.log("saved:" + sequenceSettings.data)
    }

    function load(){
        if (sequenceSettings.data) {
          clear()
          var datamodel = JSON.parse(sequenceSettings.data)
          for (var i = 0; i < datamodel.length; ++i) {
              append(datamodel[i])
          }
        }
       console.log("loaded:" + sequenceSettings.data)
    }
}




