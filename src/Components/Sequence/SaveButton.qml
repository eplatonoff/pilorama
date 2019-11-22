import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: save
    width: 40
    height: 40

    MouseArea {
        id: prefsIconTrigger
        x: 13
        y: 13
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor

        onReleased: {
        }
    }

    Image {
        source: "../../assets/img/save.svg"
        fillMode: Image.PreserveAspectFit

        property bool prefsToggle: false
        anchors.horizontalCenter: parent.horizontalCenter
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


