import QtQuick 2.0
import Qt.labs.settings 1.0

ListModel {

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
        var col = colors.list()
        var cl = col.length
        var rand = Math.floor(Math.random() * cl)
        return col[rand]

    }

    function save(){
        var datamodel = []
        for (var i = 0; i < count; ++i) datamodel.push(get(i))
        datastore = JSON.stringify(datamodel)
    }
}




