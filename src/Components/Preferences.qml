import QtQuick 2.0

Item {

    anchors.bottomMargin: 0
    anchors.topMargin: 40
    anchors.fill: parent

    Column {

        id: prefs

        spacing: 7

        property real dotSize: 10
        property real dotSpacing: 3
        property real cellHeight: 19
        anchors.fill: parent

        Item {
            id: pomoLine
            height: parent.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Rectangle {
                id: pomoDot
                width: prefs.dotSize
                height: prefs.dotSize
                color: appSettings.darkMode ? colors.pomodoroDark : colors.pomodoroLight
                radius: 30
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                width: 115
                height: 19
                text: qsTr("pomodoro:")
                color: appSettings.darkMode ? colors.accentDark : colors.accentLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: pomoDot.right
                anchors.leftMargin: 7
                font.pixelSize: 16
            }


            TextInput {
                id: pomoTime
                width: 30
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                text: durationSettings.pomodoro / 60
                anchors.left: pomoDot.right
                anchors.leftMargin: 120
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16

                onTextChanged: {durationSettings.pomodoro = pomoTime.text * 60}
            }

            Text {
                width: 30
                text: qsTr("min")
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: pomoTime.right
                anchors.leftMargin: 3
                font.pixelSize: 16
            }

        }

        Item {
            id: pauseLine
            height: parent.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Rectangle {
                id: pauseDot
                width: prefs.dotSize
                height: prefs.dotSize
                color: appSettings.darkMode ? colors.shortBreakDark : colors.shortBreakLight
                radius: 30
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                width: 115
                height: 19
                text: qsTr("short break:")
                color: appSettings.darkMode ? colors.accentDark : colors.accentLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: pauseDot.right
                anchors.leftMargin: 7
                font.pixelSize: 16
            }


            TextInput {
                id: pauseTime
                width: 30
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                text: durationSettings.pause / 60
                anchors.left: pauseDot.right
                anchors.leftMargin: 120
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16

                onTextChanged: {durationSettings.pause = pauseTime.text * 60}
            }

            Text {
                width: 30
                text: qsTr("min")
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: pauseTime.right
                anchors.leftMargin: 3
                font.pixelSize: 16
            }

        }

        Item {
            id: breakLine
            height: parent.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Rectangle {
                id: breakDot
                width: prefs.dotSize
                height: prefs.dotSize
                color: appSettings.darkMode ? colors.longBreakDark : colors.longBreakLight
                radius: 30
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                width: 115
                height: 19
                text: qsTr("long break:")
                color: appSettings.darkMode ? colors.accentDark : colors.accentLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: breakDot.right
                anchors.leftMargin: 7
                font.pixelSize: 16
            }


            TextInput {
                id: breakTime
                width: 30
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                text: durationSettings.breakTime / 60
                anchors.left: breakDot.right
                anchors.leftMargin: 120
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16

                onTextChanged: {durationSettings.breakTime = breakTime.text * 60}
            }

            Text {
                width: 30
                text: qsTr("min")
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: breakTime.right
                anchors.leftMargin: 3
                font.pixelSize: 16
            }

        }

        Item {
            id: repeatLine
            height: parent.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Text {
                width: 115
                height: 19
                text: qsTr("long break every:")
                color: appSettings.darkMode ? colors.accentDark : colors.accentLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: breakDot.right
                anchors.leftMargin: 7
                font.pixelSize: 16
            }


            TextInput {
                id: repeatTime
                width: 30
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                text: durationSettings.repeatBeforeBreak
                anchors.left: parent.left
                anchors.leftMargin: 120 + prefs.dotSize
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16

                onTextChanged: {durationSettings.repeatBeforeBreak = repeatTime.text}
            }

            Text {
                width: 30
                text: qsTr("pomodoro")
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: repeatTime.right
                anchors.leftMargin: 3
                font.pixelSize: 16
            }

        }

        Item {
            id: splitToSequence
            height: parent.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Text {
                id: splitToSequenceLabel
                width: 115
                height: 19
                text: qsTr("split to sequence:")
                color: appSettings.darkMode ? colors.accentDark : colors.accentLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 0
                font.pixelSize: 16
            }

            Text {
                id: splitToSequenceSetting
                width: 30
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                text: appSettings.splitToSequence
                anchors.leftMargin: 150
                anchors.left: parent.left
                horizontalAlignment: Text.AlignLeft
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16
            }

            MouseArea {
                id: splitToSequenceTrigger
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    appSettings.splitToSequence = !appSettings.splitToSequence
                }
            }
        }

    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
