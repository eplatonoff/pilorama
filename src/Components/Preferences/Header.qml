import QtQuick 2.0

Rectangle {
    id: rectangle
    height: 50
    width: parent.width
    color: colors.getColor("bg")

    property real headingFontSize: 18


    BackButton {
        id: backButton
    }

    Text {
        text: qsTr('Preferences')
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: headingFontSize
        color: colors.getColor("dark")
    }

}

