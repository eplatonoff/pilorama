import QtQuick 2.0
import QtGraphicalEffects 1.12

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
        anchors.right: prefsButton.left

        MouseArea {
            id: paddButtonTrigger
            x: 13
            y: 13
            anchors.rightMargin: 0
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor

            onReleased: {
                masterModel.add()
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

    PrefsButton {
        id: prefsButton
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}
