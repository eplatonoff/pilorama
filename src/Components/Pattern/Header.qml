import QtQuick 2.0
import QtGraphicalEffects 1.12

Rectangle {
    id: rectangle
    height: 40
    color: colors.get()

    property real fontSize: 18

    Text {
        text: qsTr('Presets')
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: fontSize
        color: colors.get("dark")
    }

    Item {
        id: backButton
        height: parent.height
        width: 40

        anchors.verticalCenter: parent.verticalCenter

        Image {
            id: backIcon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "../../assets/img/back.svg"
            fillMode: Image.PreserveAspectFit


            ColorOverlay{
                id: backOverlay
                source: parent
                color: colors.get('light')
                anchors.fill: parent
                antialiasing: true
            }
        }
        MouseArea {
            id: backTrigger
            anchors.fill: parent
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor
            onReleased: views.pop()
        }
    }
}

