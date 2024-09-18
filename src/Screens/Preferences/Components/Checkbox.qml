import QtQuick

import "../../../Components"

Item {
    id: checkbox

    property bool checked: false

    height: parent.height
    width: 30

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('lighter')
        height: 14
        radius: 3
        width: 14
    }
    Icon {
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('dark')
        glyph: "\uea0c"
        visible: checkbox.checked

        Behavior on opacity {
            PropertyAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
