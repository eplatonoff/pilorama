import QtQuick
import ".."

Rectangle {
    id: rectangle
    width: parent.width
    anchors.bottomMargin: 0
    color: "transparent"

    visible: !sequence.blockEdits
    height: sequence.blockEdits ? 0 : 42

    property real fontSize: 14

    Behavior on height {
        NumberAnimation {
            property: "height"
            duration: 150
        }}

        Rectangle {
        id: layoutDivider
        height: 1
        width: parent.width - 6
        color: colors.getColor("lighter")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        property real padding: 18

    }

    Rectangle {

        width: parent.width
        height: 32
        anchors.bottom: parent.bottom
        color: "transparent"

    Rectangle {
        id: addButton

        color:  "transparent"
        radius: 3
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: saveButton.right
        anchors.right: parent.right

        MouseArea {
            id: paddButtonTrigger
            anchors.rightMargin: 0
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor

            onReleased: {
                masterModel.add()
                focus = true
            }
        }

        Item {

            height: parent.height

            anchors.left: parent.left
            anchors.leftMargin: 32

            Icon {
                id: addIcon
                glyph: "\uea10"
                color: colors.getColor("mid")
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: qsTr('Add split')
                anchors.left: addIcon.right
                anchors.verticalCenter: parent.verticalCenter

                font.family: localFont.name
                font.pixelSize: fontSize

                renderType: Text.NativeRendering

                color: colors.getColor("dark")
            }
        }


    }

    Icon {
        id: loadButton
        glyph: "\uea0b"
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        onReleased: { fileDialogue.openDialogue() }

    }

    Icon {
        id: saveButton
        glyph: "\uea07"
        anchors.left: loadButton.right
        anchors.verticalCenter: parent.verticalCenter

        onReleased: { fileDialogue.saveDialogue() }

    }
}
}
