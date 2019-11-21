import QtQuick 2.0
import QtGraphicalEffects 1.12

Rectangle {
    id: rectangle
    height: 40
    color: colors.getColor("bg")

    property real fontSize: 18

    Text {
        text: qsTr('Sequence')
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: fontSize
        color: colors.getColor("dark")
    }

}

