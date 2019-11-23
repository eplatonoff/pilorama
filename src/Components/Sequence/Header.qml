import QtQuick 2.0
import QtGraphicalEffects 1.12

Rectangle {
    id: rectangle
    height: 40
    width: parent.width
    color: colors.getColor("bg")

    property real fontSize: 18

    Text {
        text: qsTr('Sequence')
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: fontSize
        color: colors.getColor("dark")
    }

//    SaveButton {
//        id: saveButton
//        anchors.verticalCenter: parent.verticalCenter
//        anchors.right: parent.right
//        anchors.rightMargin: 0
//    }

}

