import QtQuick 2.0
import QtGraphicalEffects 1.12

import "Sequence"

Item {
    id: startScreen
    visible: window.clockMode === "start"
    width: 150
    height: 150
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    property real headingFontSize: 23
    property real fontSize: 14

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
//        cursorShape: Qt.PointingHandCursor

        onPressed: { focus = true }
    }


    TextInput {
        id: presetName
        text: masterModel.title
        anchors.top: parent.top
        anchors.topMargin: 40
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        layer.enabled: true
        wrapMode: TextEdit.NoWrap

        readOnly: sequence.blockEdits
        selectByMouse : !sequence.blockEdits

        font.pixelSize: startScreen.headingFontSize
        font.family: openSans.name
        renderType: Text.NativeRendering
        antialiasing: true

        selectedTextColor : colors.getColor('dark')
        selectionColor : colors.getColor('lighter')

        color: colors.getColor("dark")

        function acceptInput(){
            masterModel.title = presetName.text
        }

        onTextChanged: { acceptInput() }
        onAccepted: { acceptInput() }

     }

    Text {
        id: totalTime
        color: colors.getColor('mid')
        text: "Total: " + masterModel.totalDuration() / 60 + " min"
        anchors.top: presetName.bottom
        anchors.topMargin: 6
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
        anchors.leftMargin: 0
        horizontalAlignment: Text.AlignHCenter
        anchors.right: parent.right
        anchors.rightMargin: 0
        font.pixelSize: startScreen.fontSize
    }


    ResetButton{
        id: play
        visible: masterModel.count > 0 && masterModel.totalDuration() > 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        label: 'Start'

        MouseArea {
            id: playtrigger
            anchors.bottomMargin: 0
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor

            onReleased: {
                window.clockMode = "pomodoro"
                pomodoroQueue.infiniteMode = true
                globalTimer.start()
                focus = true

            }
        }
    }


}

/*##^##
Designer {
    D{i:2;anchors_width:30}
}
##^##*/
