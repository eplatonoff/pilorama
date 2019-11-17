import QtQuick 2.13

Item {
    property color bgDark: "#282828"
    property color bgLight: "#F3F3F3"
//        property color bgLight: "#EFEEE9"

    property color fakeDark: "#4F5655"
    property color fakeLight: "#D0CBCC"
//        property color fakeLight: "#CEC9B6"

    property color accentDark: "#859391"
    property color accentLight: "#999394"
//        property color accentLight: "#968F7E"

    property color accentTextDark: "#fff"
    property color accentTextLight: "#0A1A39"
//        property color accentTextLight: "#000"

    property color pomodoroLight: "#E26767"
    property color pomodoroDark: "#C23E3E"

    property color shortBreakLight: "#7DCF6F"
    property color shortBreakDark: "#5BB44C"

    property color longBreakLight: "#6F85CF"
    property color longBreakDark: "#5069BE"

    function list(){
        const colors = ["red", "orange", "yellow", "green", "blue", "violet"]
        return colors
    }


    function get(color) {
        var c
        if (appSettings.darkMode){
            switch (color){
            case "red":
                c = "#C23E3E"; break;
            case "orange":
                c = "#BF733D"; break;
            case "yellow":
                c = "#C8AC4B"; break;
            case "green":
                c = "#5BB44C"; break;
            case "blue":
                c = "#5069BE"; break;
            case "violet":
                c = "#A647BE"; break;
            case "dark":
                c = "#fff"; break;
            case "mid":
                c = "#859391"; break;
            case "light":
                c = "#4F5655"; break;
            default:
                c = "#282828"; break
            }
        } else {
            switch (color){
            case "red":
                c = "#E26767"; break;
            case "orange":
                c = "#E09B49"; break;
            case "yellow":
                c = "#E7D054"; break;
            case "green":
                c = "#7DCF6F"; break;
            case "blue":
                c = "#6F85CF"; break;
            case "violet":
                c = "#B66FCF"; break;
            case "dark":
                c = "#3E393A"; break;
            case "mid":
                c = "#999394"; break;
            case "light":
                c = "#D0CBCC"; break;
            default:
                c = "#F3F3F3"; break
            }
        }
            return c
    }
}
