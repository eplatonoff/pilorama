import QtQuick 2.4
import Qt5Compat.GraphicalEffects

Item {
    id: element

    width: 50
    height: 50
    visible: !appSettings.followSystemTheme

    Image {
        fillMode: Image.PreserveAspectFit

        sourceSize.width: 24
        sourceSize.height: 24

        property string iconDark: "qrc:/assets/img/sun.svg"
        property string iconLight: "qrc:/assets/img/moon.svg"
        anchors.right: parent.right
        anchors.rightMargin: 3
        anchors.top: parent.top
        anchors.topMargin: 3

        source: appSettings.darkMode ? iconDark : iconLight

        ColorOverlay{
            id: modeSwitchOverlay
            anchors.fill: parent
            source: parent
            color: colors.getColor('light')
        }
    }

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

}

