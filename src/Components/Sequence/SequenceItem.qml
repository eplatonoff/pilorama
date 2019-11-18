import QtQuick 2.0
import QtGraphicalEffects 1.12
import QtQml.Models 2.13

Item {
    id: sequenceItem
    height: 38
    width: parent.width

    z: itemDragTrigger.held ? 2 : 1
    Drag.active: itemDragTrigger.held
    Drag.source: sequenceItem
    Drag.hotSpot: Qt.point(0, height)

    MouseArea {
        id: itemHover
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            itemControls.visible = true
            itemControls.width = 40
        }

        onExited: {
            itemControls.visible = false
            itemControls.width = 0
        }
    }

    MouseArea {
        id: itemDragTrigger

        width: 40
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        propagateComposedEvents: true
        cursorShape: Qt.OpenHandCursor

        property bool held: false

        drag.target: held ? parent : undefined
        drag.axis: Drag.YAxis

        onPressed: {
            cursorShape = Qt.ClosedHandCursor
            held = true


//            var datamodel = []
//            for (var i = 0; i < DelegateModel.count; ++i) datamodel.push(DelegateModel.get(i))
//                        console.log(JSON.stringify(datamodel))
        }
        onReleased: {
            cursorShape = Qt.OpenHandCursor
            held = false

//            var datamodel = []
//            for (var i = 0; i < DelegateModel.count; ++i) datamodel.push(DelegateModel.get(i))
//                        console.log(JSON.stringify(datamodel))
        }
    }

    DropArea {
        anchors.right: parent.right
        anchors.left: parent.left
        height: 5
        anchors.verticalCenter: parent.verticalCenter

        onEntered: {
            console.log("new position:" + index, drag.source.DelegateModel.itemsIndex)
            visualModel.items.move(
                            drag.source.DelegateModel.itemsIndex,
                            index
                           )
        }
    }

    Rectangle {
        id: sqeuenceLine
        anchors.fill: parent
        color: colors.get()

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
            horizontalAlignment: Text.AlignLeft
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
            color: colors.get('dark')
            text: Math.trunc( model.duration / 60 )
            horizontalAlignment: Text.AlignRight
            anchors.right: itemtimeMin.left
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: parent.fontSize

//            onTextChanged: {model.duration = itemtime.text * 60}
        }

        Text {
            id: itemtimeMin
            width: 30
            text: qsTr("min")
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            color: colors.get('mid')
            font.pixelSize: parent.fontSize
        }

        Rectangle {
            id: itemControls
            visible: false
            color: colors.get()

            height: parent.height
            width: 0

            Behavior on width { PropertyAnimation { duration: 100 } }

            anchors.right: parent.right
            anchors.rightMargin: 0

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
                    propagateComposedEvents: true
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
                    propagateComposedEvents: true
                    cursorShape: Qt.PointingHandCursor
                    onReleased: sequenceModel.remove(index)
                }
            }
        }
    }

}


