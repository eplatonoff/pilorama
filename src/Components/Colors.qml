import QtQuick

QtObject {
    id: colors

    property var colorMap: ({
        "bg": {
            "night": "#282828",
            "day": "#F3F3F3",
            "trayNight": "#353535",
            "trayDay": "#F6F6F6",
            "regular": false
        },
        "dark": {
                "night": "#fff",
                "day": "#3E393A",
                "trayNight": "#EFEFEF",
                "trayDay": "#3C3C3C",
                "regular": false
            },
        "mid": {
            "night": "#959C9B",
            "day": "#878183",
            "trayNight": "#909090",
            "trayDay": "#AEAEAE",
            "regular": false
        },
        "light": {
            "night": "#616665",
            "day": "#BAB4B4",
            "trayNight": "#474747",
            "trayDay": "#DCDCDC",
            "regular": false
        },
        "lighter": {
            "night": "#454747",
            "day": "#E0DDDD",
            "trayNight": "#474747",
            "trayDay": "#DCDCDC",
            "regular": false
        },
        "mid gray": {
            "night": "#6A6C6E",
            "day": "#6A6C6E",
            "trayNight": "#6A6C6E",
            "trayDay": "#6A6C6E",
            "regular": false
        },
        "red": {
            "night": "#C23E3E",
            "day": "#E26767",
            "trayNight": "#E94040",
            "trayDay": "#D34E4E",
            "regular": true
        },
        "orange": {
            "night": "#BF733D",
            "day": "#E09B49",
            "trayNight": "#DB8825",
            "trayDay": "#DC8825",
            "regular": true
        },
        "yellow": {
            "night": "#C8AC4B",
            "day": "#E7D054",
            "trayNight": "#D3B200",
            "trayDay": "#D1AF00",
            "regular": true
        },
        "green": {
            "night": "#5BB44C",
            "day": "#7DCF6F",
            "trayNight": "#73D637",
            "trayDay": "#5ABE1D",
            "regular": true
        },
        "cyan": {
            "night": "#339BA7",
            "day": "#59BDC9",
            "trayNight": "#1DBED0",
            "trayDay": "#0BAEC0",
            "regular": true
        },
        "blue": {
            "night": "#5275E9",
            "day": "#7291F6",
            "trayNight": "#698AFF",
            "trayDay": "#6387FF",
            "regular": true
        },
        "violet": {
            "night": "#A647BE",
            "day": "#B66FCF",
            "trayNight": "#D15BFB",
            "trayDay": "#C729FF",
            "regular": true
        },
        "osxClose": {
            "night": "#EC6A5E",
            "day": "#EC6A5E",
            "regular": false
        },
        "osxMinimize": {
            "night": "#F4BF4F",
            "day": "#F4BF4F",
            "regular": false
        },
        "osxMaximize": {
            "night": "#62C654",
            "day": "#62C654",
            "regular": false
        },
        "osxInactive": {
            "night": "#4C4C48",
            "day": "#CCCCCA",
            "regular": false
        }
    })

    function list() {
        var colorNames = []
        for (var key in colorMap) {
            if (colorMap.hasOwnProperty(key) && colorMap[key].regular) {
                colorNames.push(key)
            }
        }
        return colorNames
    }

    function getColor(color) {
        if (colorMap.hasOwnProperty(color)) {
            if (appSettings.darkMode) {
                return colorMap[color].night
            } else {
                return colorMap[color].day
            }
        }
        return null
    }

    function getThemeColor(color) {
        if (colorMap.hasOwnProperty(color)) {
            const entry = colorMap[color]
            if (systemPalette.systemDarkMode) {
                return entry.trayNight !== undefined ? entry.trayNight : entry.night
            } else {
                return entry.trayDay !== undefined ? entry.trayDay : entry.day
            }
        }
        return null
    }
}
