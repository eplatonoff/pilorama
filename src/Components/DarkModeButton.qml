import QtQuick 2.4
import QtGraphicalEffects 1.12

Image {
    sourceSize.width: 23
    sourceSize.height: 23
    antialiasing: true
    smooth: true
    fillMode: Image.PreserveAspectFit

    property string iconDark: "../assets/img/sun.svg"
    property string iconLight: "../assets/img/moon.svg"
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0

    source: appSettings.darkMode ? iconDark : iconLight

    ColorOverlay{
        id: modeSwitchOverlay
        anchors.fill: parent
        source: parent
        color: appSettings.darkMode ? colors.fakeDark : colors.fakeLight
        antialiasing: true
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
