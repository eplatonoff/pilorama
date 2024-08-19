import QtQuick
import Qt5Compat.GraphicalEffects

Item {

    width: 30
    height: parent.height

    Image {
        source: "../../assets/img/save.svg"
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: false

        sourceSize.width: 24
        sourceSize.height: 24

        property bool prefsToggle: false

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter


        ColorOverlay{
            id: prefsIconOverlay
            anchors.fill: parent
            source: parent
            color: colors.getColor("light")
            antialiasing: false
            smooth: true
        }
    }

    MouseArea {
        id: prefsIconTrigger
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        cursorShape: Qt.PointingHandCursor

        onReleased: { fileDialogue.saveDialogue() }
    }

}


