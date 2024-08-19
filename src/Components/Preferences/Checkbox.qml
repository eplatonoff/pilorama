import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: checkbox

    width: 30
    height: parent.height

    property bool checked: false

    Rectangle{
        width: 14
        height: 14
        color: colors.getColor('lighter')
        radius: 3
        anchors.left: parent.left
        anchors.leftMargin: 5


        anchors.verticalCenter: parent.verticalCenter
    }
    Image {
        opacity: checkbox.checked
        anchors.verticalCenter: parent.verticalCenter
        sourceSize.width: 24
        sourceSize.height: 24
        antialiasing: true
        smooth: true
        fillMode: Image.PreserveAspectFit

        Behavior on opacity {PropertyAnimation{duration: 200; easing.type: Easing.OutQuad}}


        source: "qrc:/assets/img/check.svg"

        ColorOverlay{
            id: modeSwitchOverlay
            anchors.fill: parent
            source: parent
            color: colors.getColor('dark')
            antialiasing: true
        }
    }

}


/*##^##
Designer {
    D{i:2;anchors_width:16}
}
##^##*/
