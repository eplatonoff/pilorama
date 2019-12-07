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
        color: colors.getColor("light")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        property real padding: 18

    }

    Rectangle {
        id: addButton

        color:  "transparent"
        radius: 3
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
//        border.color: colors.getColor("light")
        anchors.left: saveButton.right
        anchors.leftMargin: 10
        anchors.right: prefsButton.left
        anchors.rightMargin: 35

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

            width: 88
            height: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
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
                    color: appSettings.darkMode ? colors.accentDark : colors.accentLight
                    antialiasing: true
                }
            }

            Text {
                text: qsTr('Add split')
                anchors.left: addIcon.right
                anchors.leftMargin: 2
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
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
    }

    SaveButton {
        id: saveButton
        anchors.left: loadButton.right
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
    }

    PrefsButton {
        id: prefsButton
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.verticalCenter: parent.verticalCenter
    }
}
