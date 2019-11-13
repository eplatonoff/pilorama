import QtQuick 2.0
import QtGraphicalEffects 1.12

Image {
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0
    source: "../assets/img/prefs.svg"
    fillMode: Image.PreserveAspectFit

    property bool prefsToggle: false

    ColorOverlay{
        id: prefsIconOverlay
        anchors.fill: parent
        source: parent
        color: appSettings.darkMode ? colors.fakeDark : colors.fakeLight
        antialiasing: true
    }

    MouseArea {
        id: prefsIconTrigger
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor

        onReleased: {
            content.currentItem === timerLayout ? content.push(preferences) : content.pop()
        }
    }
}
