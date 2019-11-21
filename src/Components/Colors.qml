import QtQuick 2.13

ListModel{
    id: colors

    property color bgDark: "#282828"
    property color bgLight: "#F3F3F3"

    property color fakeDark: "#4F5655"
    property color fakeLight: "#D0CBCC"

    property color accentDark: "#859391"
    property color accentLight: "#999394"

    property color accentTextDark: "#fff"
    property color accentTextLight: "#0A1A39"

    property color pomodoroLight: "#E26767"
    property color pomodoroDark: "#C23E3E"

    property color shortBreakLight: "#7DCF6F"
    property color shortBreakDark: "#5BB44C"

    property color longBreakLight: "#6F85CF"
    property color longBreakDark: "#5069BE"

    ListElement{
        name: "bg"
        night: "#282828"
        day: "#F3F3F3"
    }

    ListElement{
        name: "dark"
        night: "#fff"
        day: "#3E393A"
    }
    ListElement{
        name: "mid"
        night: "#859391"
        day: "#999394"
    }
    ListElement{
        name: "light"
        night: "#4F5655"
        day: "#D0CBCC"
    }


    // Colors from index 3


    ListElement{
        name: "red"
        night: "#C23E3E"
        day: "#E26767"
    }
    ListElement{
        name: "orange"
        night: "#BF733D"
        day: "#E09B49"
    }
    ListElement{
        name: "yellow"
        night: "#C8AC4B"
        day: "#E7D054"
    }
    ListElement{
        name: "green"
        night: "#5BB44C"
        day: "#7DCF6F"
    }
    ListElement{
        name: "blue"
        night: "#5069BE"
        day: "#6F85CF"
    }
    ListElement{
        name: "violet"
        night: "#A647BE"
        day: "#B66FCF"
    }

    function list(){
        var colors = []
        for(var i= 4; i<count; i++){
           colors.push(get(i).name)
        }
        return colors
    }

    function getColor(color) {
        let colorIndex = 0
        for(var i= 0; i<count; i++){
            if(color === get(i).name){
                colorIndex = i
                break;
            } else if(!color) {
                colorIndex = 0
                break;
            }
        }
        if (appSettings.darkMode){ return get(colorIndex).night }
        else { return get(colorIndex).day  }
    }
}
