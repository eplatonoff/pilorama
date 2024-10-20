import QtQuick

Item {
    id: button

    property string label: 'Button'

    height: 34
    width: 80

    Rectangle {
        anchors.fill: parent
        color: colors.getColor("lighter")
        radius: 22

        Text {
            id: buttonText

            anchors.fill: parent
            color: colors.getColor("dark")
            font.family: localFont.name
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
            text: button.label
            verticalAlignment: Text.AlignVCenter
        }
    }
}
