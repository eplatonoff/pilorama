import QtQuick

Rectangle {
    id: rectangle
    height: 32
    width: parent.width
    color: "transparent"

    property real headingFontSize: 18


    BackButton {
        id: backButton
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

