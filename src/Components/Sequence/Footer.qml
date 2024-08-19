import QtQuick
import Qt5Compat.GraphicalEffects

Rectangle {
    id: rectangle
    width: parent.width
    anchors.bottomMargin: 0
    color: "transparent"

    visible: !sequence.blockEdits
    height: sequence.blockEdits ? 0 : 50

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

            Image {
                id: addIcon
                source: "../../assets/img/add.svg"
                fillMode: Image.PreserveAspectFit

                sourceSize.height: 24
                sourceSize.width: 24

                property bool prefsToggle: false
                anchors.verticalCenter: parent.verticalCenter

                ColorOverlay{
                    id: addIconOverlay
                    anchors.fill: parent
                    source: parent
                    color: colors.getColor("mid")
                    antialiasing: true
                }
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

    LoadButton {
        id: loadButton
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
    }

    SaveButton {
        id: saveButton
        anchors.left: loadButton.right
        anchors.verticalCenter: parent.verticalCenter
    }
}
