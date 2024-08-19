import QtQuick
import Qt5Compat.GraphicalEffects

Item {

    width: 28
    height: parent.height

    Image {
        source: "../../assets/img/prefs.svg"
        fillMode: Image.PreserveAspectFit

        sourceSize.height: 24
        sourceSize.width: 24

        property bool prefsToggle: false

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        ColorOverlay{
            id: prefsIconOverlay
            anchors.fill: parent
            source: parent
            color: colors.getColor("light")
        }
    }

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

}


