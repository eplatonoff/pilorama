import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: back
    width: 50
    height: 50

    MouseArea {
        id: backTrigger
        x: 13
        y: 13
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor

        onReleased: {
            stack.pop()
        }
    }

    Image {
        source: "../../assets/img/back.svg"
        fillMode: Image.PreserveAspectFit

        property bool prefsToggle: false
        anchors.verticalCenter: parent.verticalCenter

        ColorOverlay{
            id: prefsIconOverlay
            anchors.fill: parent
            source: parent
            color: colors.getColor("light")
            antialiasing: true
        }
    }

}
