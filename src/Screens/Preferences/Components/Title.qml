import QtQuick

import "../../../Components"

Rectangle {
    id: rectangle

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    color: "transparent"
    height: 24

    FaIcon {
        id: backButton

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        glyph: "\uf053"

        onReleased: {
            stack.pop();
        }
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor("dark")
        font.family: localFont.name
        font.pixelSize: 18
        font.weight: Font.Bold
        renderType: Text.NativeRendering
        text: qsTr('PREFERENCES')
    }
}
