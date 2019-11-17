import QtQuick 2.0

Rectangle {
    id: rectangle
    height: 40
    color: colors.get()

    property real fontSize: 18

    Text {
        text: qsTr('Pomodoro sequence')
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: fontSize
        color: colors.get("dark")
    }
}
