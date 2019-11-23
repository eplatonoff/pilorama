import QtQuick 2.0
import QtGraphicalEffects 1.12

Rectangle {
    id: rectangle
    height: 40
    width: parent.width
    color: colors.getColor("bg")

    property real headingFontSize: 18
    property real fontSize: 14

    Rectangle {
        id: layoutDivider
        height: 1
        width: parent.width
        color: colors.getColor("light")
        anchors.top: parent.top

        property real padding: 18

    }


    Text {
        text: qsTr('Sequence')
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: headingFontSize
        color: colors.getColor("dark")
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
        font.pixelSize: fontSize
    }

    Text {
        id: itemtimeMin
        width: 30
        text: qsTr("min")
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('mid')
        font.pixelSize: fontSize
    }

//    SaveButton {
//        id: saveButton
//        anchors.verticalCenter: parent.verticalCenter
//        anchors.right: parent.right
//        anchors.rightMargin: 0
//    }

}

