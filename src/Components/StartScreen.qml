import QtQuick

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

        font.family: localFont.name
        font.pixelSize: startScreen.headingFontSize

        renderType: Text.NativeRendering
        antialiasing: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            acceptedButtons: Qt.LeftButton
            propagateComposedEvents: true
            onPressed: (mouse) => { mouse.accepted = false }
        }

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

        font.family: localFont.name
        font.pixelSize: startScreen.fontSize
    }


    TimerControls {
        id: play
        visible: masterModel.count > 0 && masterModel.totalDuration() > 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        label: 'Start'

        onStartResetClicked: {
            window.clockMode = "pomodoro"
            pomodoroQueue.infiniteMode = true
            globalTimer.start()
        }
    }


}
