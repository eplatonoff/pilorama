import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    visible: window.clockMode === "start"
    width: 150
    height: 150
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    Image {
        id: startPomoIcon
        anchors.left: parent.left
        anchors.leftMargin: 16
        sourceSize.height: 45
        sourceSize.width: 45
        antialiasing: true
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "../assets/img/play.svg"

        ColorOverlay{
            id: startPomoOverlay
            anchors.fill: parent
            source: parent
            color: appSettings.darkMode ? colors.pomodoroDark : colors.pomodoroLight
            antialiasing: true
        }

        MouseArea {
            id: startPomoTrigger
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor

            onReleased: {
                window.clockMode = "pomodoro"
                pomodoroQueue.infiniteMode = true
                globalTimer.start()
            }
        }
    }

    Column {
        id: column
        y: 54
        width: 54
        height: 46
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        anchors.left: startPomoIcon.right
        anchors.leftMargin: 9

        Item {
            id: pomodoroLine
            height: 12
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            Rectangle {
                width: 7
                height: 7
                radius: 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 0
                color: appSettings.darkMode ? colors.pomodoroDark : colors.pomodoroLight
            }

            Text {
                height: 11
                text: (durationSettings.pomodoro / 60) + " min"
                verticalAlignment: Text.AlignVCenter
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                font.pixelSize: 11
            }

        }
        Item {
            id: shortBreakLine
            height: 12
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            Rectangle {
                width: 7
                height: 7
                radius: 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 0
                color: appSettings.darkMode ? colors.shortBreakDark : colors.shortBreakLight
            }

            Text {
                height: 11
                text: (durationSettings.pause / 60) + " min"
                verticalAlignment: Text.AlignVCenter
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                font.pixelSize: 11
            }

        }
        Item {
            id: longBreakLine
            height: 12
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            Rectangle {
                width: 7
                height: 7
                radius: 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 0
                color: appSettings.darkMode ? colors.longBreakDark : colors.longBreakLight
            }

            Text {
                height: 11
                text: (durationSettings.breakTime / 60) + " min"
                verticalAlignment: Text.AlignVCenter
                color: appSettings.darkMode ? colors.accentTextDark : colors.accentTextLight
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                font.pixelSize: 11
            }

        }
    }
}
