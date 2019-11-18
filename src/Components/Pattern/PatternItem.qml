import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: patternItem
    height: 38
    width: parent.width

    MouseArea {
        id: itemHover
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            patternControls.visible = true
            patternControls.width = 40
        }

        onExited: {
            patternControls.visible = false
            patternControls.width = 0
        }
    }


    Rectangle {
        id: patternLine
        anchors.fill: parent
        color: colors.get()

        property real fontSize: 14


        Text {
            id: patternName
            text: model.name
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: parent.fontSize
            color: colors.get('dark')
            anchors.verticalCenter: parent.verticalCenter

        }


        Rectangle {
            id: patternControls
            visible: false
            color: colors.get()

            height: parent.height
            width: 0

            Behavior on width { PropertyAnimation { duration: 100 } }

            anchors.right: parent.right
            anchors.rightMargin: 0

            Item {
                id: close
                height: parent.height
                width: 20

                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: closeIcon
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    source: "../../assets/img/close.svg"
                    fillMode: Image.PreserveAspectFit


                    ColorOverlay{
                        id: closeOverlay
                        source: parent
                        color: colors.get('light')
                        anchors.fill: parent
                        antialiasing: true
                    }
                }
                MouseArea {
                    id: closeTrigger
                    anchors.fill: parent
                    propagateComposedEvents: true
                    cursorShape: Qt.PointingHandCursor
                    onReleased: patternModel.remove(index)
                }
            }
        }


    }

}

