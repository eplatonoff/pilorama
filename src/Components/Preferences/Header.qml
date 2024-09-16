import QtQuick
import ".."

Rectangle {
    id: rectangle
    height: 32
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.left: parent.left
    color: "transparent"
    anchors.margins: 16

    property real headingFontSize: 18

    Icon {
        id: backButton
        glyph: "\uea08"
        onReleased: {
            stack.pop()
        }
    }

    Text {
        text: qsTr('Preferences')
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        font.family: localFont.name
        font.pixelSize: headingFontSize

        color: colors.getColor("dark")

        renderType: Text.NativeRendering

    }

}

