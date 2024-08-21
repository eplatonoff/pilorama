import QtQuick

import ".."

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

    Icon {
        visible: checkbox.checked
        glyph: "\uea0c"
        color: colors.getColor('dark')
        anchors.verticalCenter: parent.verticalCenter
        Behavior on opacity {PropertyAnimation{duration: 200; easing.type: Easing.OutQuad}}

    }

}
