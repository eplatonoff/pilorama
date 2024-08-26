import QtQuick

ListModel{
    id: colors

    ListElement{
        name: "bg"
        night: "#282828"
        day: "#F3F3F3"
        trayNight: "#353535"
        trayDay: "#F6F6F6"
    }

    ListElement{
        name: "dark"
        night: "#fff"
        day: "#3E393A"
        trayNight: "#EFEFEF"
        trayDay: "#3C3C3C"
    }
    ListElement{
        name: "mid"
        night: "#959C9B"
        day: "#878183"
        trayNight: "#909090"
        trayDay: "#AEAEAE"
    }
    ListElement{
        name: "light"
        night: "#616665"
        day: "#BAB4B4"
        trayNight: "#474747"
        trayDay: "#DCDCDC"
    }
    ListElement{
        name: "lighter"
        night: "#454747"
        day: "#E0DDDD"
        trayNight: "#474747"
        trayDay: "#DCDCDC"
    }

    ListElement{
        name: "mid gray"
        night: "#6A6C6E"
        day: "#6A6C6E"
        trayNight: "#6A6C6E"
        trayDay: "#6A6C6E"
    }

    // Colors from index 6


    ListElement{
        name: "red"
        night: "#C23E3E"
        day: "#E26767"
        trayNight: "#E94040"
        trayDay: "#D34E4E"
    }
    ListElement{
        name: "orange"
        night: "#BF733D"
        day: "#E09B49"
        trayNight: "#DB8825"
        trayDay: "#DC8825"
    }
    ListElement{
        name: "yellow"
        night: "#C8AC4B"
        day: "#E7D054"
        trayNight: "#D3B200"
        trayDay: "#D1AF00"
    }
    ListElement{
        name: "green"
        night: "#5BB44C"
        day: "#7DCF6F"
        trayNight: "#73D637"
        trayDay: "#5ABE1D"
    }
    ListElement{
        name: "cyan"
        night: "#339BA7"
        day: "#59BDC9"
        trayNight: "#1DBED0"
        trayDay: "#0BAEC0"
    }
    ListElement{
        name: "blue"
        night: "#5275E9"
        day: "#7291F6"
        trayNight: "#698AFF"
        trayDay: "#6387FF"
    }
    ListElement{
        name: "violet"
        night: "#A647BE"
        day: "#B66FCF"
        trayNight: "#D15BFB"
        trayDay: "#C729FF"
    }

    function list(){
        var colors = []
        for(var i= 6; i<count; i++){
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

    function getThemeColor(color) {
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
        if (systemPalette.sysemDarkMode){ return get(colorIndex).trayNight }
        else { return get(colorIndex).trayDay  }
    }
}
