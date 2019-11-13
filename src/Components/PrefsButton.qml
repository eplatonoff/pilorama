import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: element
    width: 50
    height: 50

    MouseArea {
        id: prefsIconTrigger
        x: 13
        y: 13
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor

        onReleased: {
            content.currentItem === timerLayout ? content.push(prefsLayout) : content.pop()
        }
    }

    Image {
        source: "../assets/img/prefs.svg"
        fillMode: Image.PreserveAspectFit

        property bool prefsToggle: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        ColorOverlay{
            id: prefsIconOverlay
            anchors.fill: parent
            source: parent
            color: appSettings.darkMode ? colors.fakeDark : colors.fakeLight
            antialiasing: true
        }
    }

}


