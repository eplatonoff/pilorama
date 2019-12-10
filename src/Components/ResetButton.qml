import QtQuick 2.0

Item{
    id: button

    width: 80
    height: 34

    property string label: 'Button'

    Rectangle {
        color: colors.getColor("lighter")
//        color: "transparent"
//        border.color: colors.getColor("light")
//        border.width: 3
        radius: 22
        anchors.fill: parent

        Text {
            id: buttonText
            text: button.label
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            font.pixelSize: 15
            color: colors.getColor("dark")

        }
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
