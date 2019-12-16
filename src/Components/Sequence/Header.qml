import QtQuick 2.0
import QtGraphicalEffects 1.12

Rectangle {
    id: rectangle
    height: 50
    width: parent.width
    color: "transparent"

    property real headingFontSize: 18
    property real fontSize: 14

    Rectangle {
        id: layoutDivider
        height: 1
        width: parent.width - 6
        color: colors.getColor("light")
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter

        property real padding: 18

    }

    TextInput {
        id: presetName
        text: masterModel.title
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter

        layer.enabled: true
        wrapMode: TextEdit.NoWrap
        readOnly: sequence.blockEdits
        selectByMouse : !sequence.blockEdits

        font.family: localFont.name
        font.pixelSize: parent.headingFontSize

        renderType: Text.NativeRendering
        antialiasing: true

        color: colors.getColor("dark")

        selectedTextColor : colors.getColor('dark')
        selectionColor : colors.getColor('light')

        function acceptInput(){
            masterModel.title = presetName.text
        }

        onTextChanged: { acceptInput() }
        onAccepted: { acceptInput() }


    }


    Text {
        id: totalTime
        width: 30
        color: colors.getColor('mid')
        text: masterModel.totalDuration() / 60
        horizontalAlignment: Text.AlignRight
        anchors.right: itemtimeMin.left
        anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter

        font.family: localFont.name
        font.pixelSize: fontSize
    }

    Text {
        id: itemtimeMin
        width: 30
        text: qsTr("min")
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('mid')

        font.family: localFont.name
        font.pixelSize: fontSize
    }
}

