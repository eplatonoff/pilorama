import QtQuick 2.0
import Qt5Compat.GraphicalEffects

Item {

    width: 30
    height: parent.height

    Image {
        source: "../../assets/img/load.svg"
        fillMode: Image.PreserveAspectFit

        sourceSize.width: 24
        sourceSize.height: 24

        property bool prefsToggle: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        ColorOverlay{
            id: loadOverlay
            anchors.fill: parent
            source: parent
            color: colors.getColor("light")
            antialiasing: true
        }
    }

    MouseArea {
        id: loadTrigger
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor

        onReleased: { fileDialogue.openDialogue() }
    }

}
