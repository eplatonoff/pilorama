import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: element
    visible: window.clockMode === "start"
    width: 150
    height: 150
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    Image {
        id: startPomoIcon
        anchors.horizontalCenter: parent.horizontalCenter
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
            color: colors.get("mid")
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
}
