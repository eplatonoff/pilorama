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
            stack.push(preferences)
        }
    }

    Image {
        source: "../assets/img/prefs.svg"
        fillMode: Image.PreserveAspectFit

        property bool prefsToggle: false
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        ColorOverlay{
            id: prefsIconOverlay
            anchors.fill: parent
            source: parent
            color: appSettings.darkMode ? colors.fakeDark : colors.fakeLight
            antialiasing: true
        }
    }

}


