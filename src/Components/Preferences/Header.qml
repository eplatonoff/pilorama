import QtQuick
import ".."

Rectangle {
    id: rectangle
    height: 32
    width: parent.width
    color: "transparent"

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

