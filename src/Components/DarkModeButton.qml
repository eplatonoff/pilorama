import QtQuick 2.4
import QtGraphicalEffects 1.12

Item {
    id: element

    width: 50
    height: 50

    MouseArea {
        id: modeSwitchArea
        x: 25
        y: 25
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor

        onReleased: {
            appSettings.darkMode = !appSettings.darkMode
        }
    }

    Image {
        sourceSize.width: 23
        sourceSize.height: 23
        antialiasing: true
        smooth: true
        fillMode: Image.PreserveAspectFit

        property string iconDark: "../assets/img/sun.svg"
        property string iconLight: "../assets/img/moon.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        source: appSettings.darkMode ? iconDark : iconLight

        ColorOverlay{
            id: modeSwitchOverlay
            anchors.fill: parent
            source: parent
            color: appSettings.darkMode ? colors.fakeDark : colors.fakeLight
            antialiasing: true
        }
    }

}

