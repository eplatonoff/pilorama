import QtQuick 2.4
import QtGraphicalEffects 1.12

Item {
    id: checkbox

    width: 38
    height: 38

    property bool checked: false

    MouseArea {
        id: modeSwitchArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor

        onReleased: {
            appSettings.darkMode = !appSettings.darkMode
        }
    }
    Rectangle{
        width: 16
        height: 16
        color: 'transparent'
        border.color: colors.getColor('light')
        radius: 3
        border.width: 2

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
    Image {
        visible: checkbox.checked
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        sourceSize.width: 23
        sourceSize.height: 23
        antialiasing: true
        smooth: true
        fillMode: Image.PreserveAspectFit


        source: "../../assets/img/check.svg"

        ColorOverlay{
            id: modeSwitchOverlay
            anchors.fill: parent
            source: parent
            color: colors.getColor('dark')
            antialiasing: true
        }
    }

}

