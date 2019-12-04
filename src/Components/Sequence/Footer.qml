import QtQuick 2.0
import QtGraphicalEffects 1.12

Rectangle {
    height: 50
    width: parent.width
    anchors.bottomMargin: 0
    color: appSettings.darkMode ? colors.bgDark : colors.bgLight

    property real fontSize: 14

    Rectangle {
        id: addButton

        visible: !sequence.blockEdits
        height: sequence.blockEdits ? 0 : 40

        color:  "transparent"
        radius: 3
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        border.color: colors.getColor("light")
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

        Behavior on height {
            NumberAnimation {
                property: "height"
                duration: 150
            }}


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

                color: appSettings.darkMode ? colors.accentDark : colors.accentLight
            }
        }


    }
}
