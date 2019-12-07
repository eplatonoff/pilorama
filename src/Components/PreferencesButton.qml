import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {

    width: 50
    height: 50

    MouseArea {
        id: prefsIconTrigger
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
        anchors.top: parent.top
        anchors.topMargin: 3
        anchors.left: parent.left
        anchors.leftMargin: 3


        ColorOverlay{
            id: prefsIconOverlay
            anchors.fill: parent
            source: parent
            color: colors.getColor("light")
        }
    }

}


