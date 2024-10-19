import QtQuick

import "../../../../Components"

Item {
    height: 32
    width: parent.width

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        TextInput {
            id: presetName

            function acceptInput() {
                timerModel.title = presetName.text;
            }

            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
            color: colors.getColor("dark")
            font.family: localFont.name
            font.pixelSize: 14
            readOnly: !sequence.editable
            renderType: Text.NativeRendering
            selectByMouse: sequence.editable
            text: timerModel.title
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

            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor('mid')
            font.family: localFont.name
            font.pixelSize: 14
            horizontalAlignment: Text.AlignRight
            text: (timerModel.totalDuration() / 60) + "′"
        }
    }
    FaIcon {
        id: editButton

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        glyph: sequence.editable ? "\uf00c" : "\uf303"
        size: 14
        tooltip: sequence.editable ? "Save" : "Edit"

        onReleased: {
            sequence.editable = !sequence.editable;
        }
    }
    Rectangle {
        id: layoutDivider

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: colors.getColor("lighter")
        height: 1
        width: parent.width
    }
}
