import QtQuick

QtObject {
    id: colors

    property var colorsMap: ({
            "bg": {
                "night": "#282828",
                "day": "#F3F3F3",
                "trayNight": "#353535",
                "trayDay": "#F6F6F6",
                "type": "ui"
            },
            "dark": {
                "night": "#fff",
                "day": "#3E393A",
                "trayNight": "#EFEFEF",
                "trayDay": "#3C3C3C",
                "type": "ui"
            },
            "mid": {
                "night": "#959C9B",
                "day": "#878183",
                "trayNight": "#909090",
                "trayDay": "#AEAEAE",
                "type": "ui"
            },
            "light": {
                "night": "#616665",
                "day": "#BAB4B4",
                "trayNight": "#474747",
                "trayDay": "#DCDCDC",
                "type": "ui"
            },
            "lighter": {
                "night": "#454747",
                "day": "#E0DDDD",
                "trayNight": "#474747",
                "trayDay": "#DCDCDC",
                "type": "ui"
            },
            "mid gray": {
                "night": "#6A6C6E",
                "day": "#6A6C6E",
                "trayNight": "#6A6C6E",
                "trayDay": "#6A6C6E",
                "type": "ui"
            },
            "red": {
                "night": "#C23E3E",
                "day": "#E26767",
                "trayNight": "#E94040",
                "trayDay": "#D34E4E",
                "type": "palette"
            },
            "orange": {
                "night": "#BF733D",
                "day": "#E09B49",
                "trayNight": "#DB8825",
                "trayDay": "#DC8825",
                "type": "palette"
            },
            "yellow": {
                "night": "#C8AC4B",
                "day": "#E7D054",
                "trayNight": "#D3B200",
                "trayDay": "#D1AF00",
                "type": "palette"
            },
            "green": {
                "night": "#5BB44C",
                "day": "#7DCF6F",
                "trayNight": "#73D637",
                "trayDay": "#5ABE1D",
                "type": "palette"
            },
            "cyan": {
                "night": "#339BA7",
                "day": "#59BDC9",
                "trayNight": "#1DBED0",
                "trayDay": "#0BAEC0",
                "type": "palette"
            },
            "blue": {
                "night": "#5275E9",
                "day": "#7291F6",
                "trayNight": "#698AFF",
                "trayDay": "#6387FF",
                "type": "palette"
            },
            "violet": {
                "night": "#A647BE",
                "day": "#B66FCF",
                "trayNight": "#D15BFB",
                "trayDay": "#C729FF",
                "type": "palette"
            },
            "osxClose": {
                "night": "#FF5F57",
                "day": "#FF6058",
                "trayNight": "#FF5F52",
                "trayDay": "#FF5F52",
                "type": "ui"
            },
            "osxMinimize": {
                "night": "#FEBC2D",
                "day": "#FEBC2C",
                "trayNight": "#FF5F52",
                "trayDay": "#FF5F52",
                "type": "ui"
            },
            "osxMaximize": {
                "night": "#29C741",
                "day": "#28C841",
                "trayNight": "#FF5F52",
                "trayDay": "#FF5F52",
                "type": "ui"
            },
            "osxInactive": {
                "night": "#4C4C48",
                "day": "#CCCCCA",
                "trayNight": "#FF5F52",
                "trayDay": "#FF5F52",
                "type": "ui"
            }
        })

    function getColor(color) {
        if (colorsMap.hasOwnProperty(color)) {
            if (appSettings.darkMode) {
                return colorsMap[color].night;
            } else {
                return colorsMap[color].day;
            }
        }
        return null;
    }
    function getThemeColor(color) {
        if (colorMap.hasOwnProperty(color)) {
            if (systemPalette.sysemDarkMode) {
                return colorMap[color].trayNight;
            } else {
                return colorMap[color].trayDay;
            }
        }
        return null;
    }
    function palette() {
        const paletteColors = [];
        for (const key in colorsMap) {
            if (colorsMap.hasOwnProperty(key) && colorsMap[key].type === "palette") {
                paletteColors.push(key);
            }
        }
        return paletteColors;
    }
}
