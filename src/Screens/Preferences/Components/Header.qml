import QtQuick

import "../../../Components"

Rectangle {
    id: rectangle


    anchors.top: parent.top
    anchors.right: parent.right
    anchors.left: parent.left
    height: 24

    color: "transparent"

    FaIcon {
        id: backButton

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        glyph: "\uf053"
        onReleased: {
            stack.pop()
        }
    }

    Text {
        text: qsTr('PREFERENCES')
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        font.family: localFont.name
        font.pixelSize: 18
        font.weight: Font.Bold

        color: colors.getColor("dark")

        renderType: Text.NativeRendering

    }

}
