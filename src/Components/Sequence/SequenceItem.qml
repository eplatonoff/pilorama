import QtQuick 2.0
import QtGraphicalEffects 1.12
import QtQml.Models 2.13

Rectangle {
    id: sequenceItem
    height: sequenceView.itemHeight
    width: sequenceView.itemWidth
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    color: colors.getColor("bg")

    property real fontSize: 14
    property int dragItemIndex: index

    Drag.active: itemDragTrigger.drag.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
    Drag.keys: ["sequenceItems"]

    states: [
        State {
            when: sequenceItem.Drag.active
            ParentChange {
                target: sequenceItem
                parent: sequenceView
            }

            AnchorChanges {
                target: sequenceItem
                anchors.verticalCenter: undefined
            }
        }
    ]

    MouseArea {
        id: itemDragTrigger
        anchors.fill: parent

        hoverEnabled: true
        propagateComposedEvents: true

        drag.target: sequenceItem

        onPressAndHold: {
            if (itemDragTrigger.drag.active) {
                sequenceItem.dragItemIndex = index;
            }
        }

        onEntered: {
            itemControls.visible = true
            itemControls.width = 40
        }

        onExited: {
            itemControls.visible = false
            itemControls.width = 0
        }
    }

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
            color: colors.getColor('light')
            antialiasing: true
        }
    }


    TextInput {
        id: itemName
        text: model.name
        horizontalAlignment: Text.AlignLeft
        anchors.left: handler.right
        anchors.leftMargin: 30
        font.pointSize: parent.fontSize

        selectByMouse : true
        selectedTextColor : colors.getColor('dark')
        selectionColor : colors.getColor('light')

        color: colors.getColor('dark')
        anchors.verticalCenter: parent.verticalCenter

        onTextChanged: {
            model.name = itemName.text
        }

    }

    TextInput {
        id: itemtime
        width: 20
        color: colors.getColor('dark')
        text: Math.trunc( model.duration / 60 )
        horizontalAlignment: Text.AlignRight
        anchors.right: itemtimeMin.left
        anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter

        selectByMouse : true
        selectedTextColor : colors.getColor('dark')
        selectionColor : colors.getColor('light')

        font.pointSize: parent.fontSize

        onTextChanged: {
            model.duration = itemtime.text * 60
        }
    }

    Text {
        id: itemtimeMin
        width: 30
        text: qsTr("min")
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('mid')
        font.pixelSize: parent.fontSize
    }

    ColorSelector {
        id: colorSelector
        anchors.leftMargin: 3
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: handler.right
        lineId: index

    }

    Rectangle {
        id: itemControls
        visible: false
        color: colors.getColor("bg")

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
                    color: colors.getColor('light')
                    antialiasing: true
                }
            }

            MouseArea {
                id: copyTrigger
                anchors.fill: parent
                propagateComposedEvents: true
                cursorShape: Qt.PointingHandCursor
                onReleased: {
                    masterModel.add(model.name, model.color, model.duration)
                }
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
                    color: colors.getColor('light')
                    anchors.fill: parent
                    antialiasing: true
                }
            }
            MouseArea {
                id: closeTrigger
                anchors.fill: parent
                propagateComposedEvents: true
                cursorShape: Qt.PointingHandCursor
                onReleased: {
                    globalTimer.stop()
                    masterModel.remove(index)
                }
            }
        }
    }
}


