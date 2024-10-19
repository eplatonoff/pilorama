import QtQuick

import "Sequence"

Item {
    id: startScreen

    property real fontSize: 14
    property real headingFontSize: 23

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    height: 150
    visible: window.clockMode === "start"
    width: 150

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true

        onPressed: {
            focus = true;
        }
    }
    TextInput {
        id: presetName

        function acceptInput() {
            masterModel.title = presetName.text;
        }

        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 40
        antialiasing: true
        color: colors.getColor("dark")
        font.family: localFont.name
        font.pixelSize: startScreen.headingFontSize
        horizontalAlignment: Text.AlignHCenter
        layer.enabled: true
        readOnly: sequence.blockEdits
        renderType: Text.NativeRendering
        selectByMouse: !sequence.blockEdits
        selectedTextColor: colors.getColor('dark')
        selectionColor: colors.getColor('lighter')
        text: masterModel.title
        verticalAlignment: Text.AlignVCenter
        wrapMode: TextEdit.NoWrap

        onAccepted: {
            acceptInput();
        }
        onTextChanged: {
            acceptInput();
        }
    }
    Text {
        id: totalTime

        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: presetName.bottom
        anchors.topMargin: 6
        color: colors.getColor('mid')
        font.family: localFont.name
        font.pixelSize: startScreen.fontSize
        horizontalAlignment: Text.AlignHCenter
        text: "Total: " + masterModel.totalDuration() / 60 + " min"
        verticalAlignment: Text.AlignVCenter
    }
    ResetButton {
        id: play

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        label: 'Start'
        visible: masterModel.count > 0 && masterModel.totalDuration() > 0

        MouseArea {
            id: playtrigger

            anchors.bottomMargin: 0
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            propagateComposedEvents: true

            onReleased: {
                window.clockMode = "pomodoro";
                pomodoroQueue.infiniteMode = true;
                globalTimer.start();
                focus = true;
            }
        }
    }
}
