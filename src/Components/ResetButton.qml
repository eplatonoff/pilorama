import QtQuick 2.0

Item{
    id: element

    anchors.bottom: parent.bottom
    anchors.bottomMargin: 0
    anchors.right: parent.right
    anchors.rightMargin: 25
    anchors.left: parent.left
    anchors.leftMargin: 25

    Rectangle {
        width: 90
        height: 36
        color: "transparent"
        border.color: appSettings.darkMode ? colors.fakeDark : colors.fakeLight
        border.width: 2
        radius: 22.5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter


        Text {
            id: digitalClockReset
            text: qsTr("Reset")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            font.pixelSize: 15
            color: appSettings.darkMode ? colors.accentDark : colors.accentLight

        }

        MouseArea {
            id: digitalClockResetTrigger
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor

            onReleased: {
                pomodoroQueue.infiniteMode = false;
                pomodoroQueue.clear();
                mouseArea._prevAngle = 0
                mouseArea._totalRotatedSecs = 0
                globalTimer.duration = 0
                globalTimer.stop()
                window.clockMode = "start"
                notifications.stopSound();
                sequence.setCurrentItem(-1)
            }
        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
