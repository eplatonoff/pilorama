import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: sequenceItem
    height: 38
    width: parent.width

    z: itemDragTrigger.held ? 2 : 1
    Drag.active: itemDragTrigger.held
    Drag.source: sequenceItem
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    MouseArea {
        id: itemDragTrigger

        width: 40
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        property bool held: false

        drag.target: held ? parent : undefined
        drag.axis: Drag.YAxis

        onPressed: {
            held = true
            console.log("drag")
        }
        onReleased: {
            held = false
            console.log("drop")
        }
    }

    Rectangle {
        id: sqeuenceLine
        anchors.fill: parent
        color: colors.get()

        Drag.active: itemDragTrigger.held
        Drag.source: itemDragTrigger
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        property real fontSize: 14

        Image {
            id: handler
            source: "../../assets/img/dragger.svg"
            fillMode: Image.PreserveAspectFit

            property bool prefsToggle: false
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter

            ColorOverlay{
                id: prefsIconOverlay
                anchors.fill: parent
                source: parent
//                color: colors.get(model.color)
                color: colors.get('light')
                antialiasing: true
            }
        }

        Rectangle {
            id: colordot
            width: 13
            height: 13
            color: colors.get(model.color)
            radius: 30
            anchors.left: handler.right
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
        }

        TextInput {
            id: itemName
            text: model.name
            anchors.left: colordot.right
            anchors.leftMargin: 7
            font.pointSize: parent.fontSize
            color: colors.get('dark')
            anchors.verticalCenter: parent.verticalCenter

            onTextChanged: {model.name = itemName.text}

        }

        TextInput {
            id: itemtime
            width: 20
            color: colors.get('mid')
            text: Math.trunc( model.duration / 60 )
            anchors.right: itemtimeMin.left
            anchors.rightMargin: 3
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: parent.fontSize

//            onTextChanged: {model.duration = itemtime.text * 60}
        }

        Text {
            id: itemtimeMin
            width: 30
            text: qsTr("min")
            anchors.right: copy.left
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            color: colors.get('mid')
            font.pixelSize: parent.fontSize
        }

        Item {
            id: copy
            height: parent.height
            width: 20
            anchors.right: close.left
            anchors.rightMargin: 0
            anchors.verticalCenter: parent.verticalCenter


            Image {
                id: copyIcon
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "../../assets/img/copy.svg"
                fillMode: Image.PreserveAspectFit

                ColorOverlay{
                    id: copyOverlay
                    anchors.fill: parent
                    source: parent
                    color: colors.get('light')
                    antialiasing: true
                }
            }

            MouseArea {
                id: copyTrigger
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onReleased: sequenceModel.add(model.name + " copy", model.color, model.duration)
            }
        }



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
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onReleased: sequenceModel.remove(index)
            }
        }


        DropArea {
            anchors.fill: parent

            onEntered: {
                visualModel.items.move(
                        drag.source.DelegateModel.itemsIndex,
                        dragArea.DelegateModel.itemsIndex)
            }
        }
    }

}

/*##^##
Designer {
    D{i:3;invisible:true}D{i:6;invisible:true}D{i:8;invisible:true}D{i:14;invisible:true}
D{i:16;invisible:true}D{i:17;invisible:true}
}
##^##*/
