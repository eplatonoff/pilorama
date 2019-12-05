import QtQuick 2.0
import QtGraphicalEffects 1.12
import QtQml.Models 2.13

Rectangle {
    id: sequenceItem
    height: sequenceView.itemHeight
    width: sequenceView.itemWidth
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    color: colors.getColor('bg')

    Behavior on color { ColorAnimation { duration: 200 }}

    property real fontSize: 14
    property int dragItemIndex: index
    property bool currentItem: delegateItem.ListView.isCurrentItem

//    property bool dim: sequence.blockEdits - currentItem
    property bool splitToSequence: preferences.splitToSequence

    function dimmer() {
        const color = colors.getColor('dark')
        const dimColor = colors.getColor('mid')

         if (!pomodoroQueue.infiniteMode && !splitToSequence && globalTimer.duration){
            return dimColor
        } else if (model.duration === 0){
            return dimColor
        } else {
            return color
        }
    }

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
        visible: !sequence.blockEdits

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
        visible: !sequence.blockEdits
        width: sequence.blockEdits ? 0 : 23
        source: "../../assets/img/dragger.svg"
        fillMode: Image.PreserveAspectFit

        Behavior on width { NumberAnimation { properties: "width"; duration: 150 }}

        property bool prefsToggle: false
        anchors.left: parent.left
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
        width: 170
        text: model.name
        horizontalAlignment: Text.AlignLeft
        anchors.left: handler.right
        anchors.leftMargin: 26
//        font.strikeout : model.duration === 0

        layer.enabled: true
        wrapMode: TextEdit.NoWrap
        readOnly: sequence.blockEdits
        selectByMouse : !sequence.blockEdits

        font.pointSize: parent.fontSize
        font.family: openSans.name
        renderType: Text.NativeRendering


        selectedTextColor : colors.getColor('dark')
        selectionColor : colors.getColor('light')

        color: sequenceItem.dimmer()
        anchors.verticalCenter: parent.verticalCenter

        function acceptInput(){
            model.name = itemName.text
        }

        onTextChanged: { acceptInput() }
        onAccepted: { acceptInput() }

    }

    TextInput {
        id: itemtime
        width: 20
        color: sequenceItem.dimmer()
        text: Math.trunc( model.duration / 60 )

        validator: IntValidator { bottom: 1; top: globalTimer.timerLimit / 60}
        inputMethodHints: Qt.ImhDigitsOnly

        wrapMode: TextEdit.NoWrap
        readOnly: sequence.blockEdits
        selectByMouse : !sequence.blockEdits
        renderType: Text.NativeRendering


        horizontalAlignment: Text.AlignRight
        anchors.right: itemtimeMin.left
        anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter

        selectedTextColor : colors.getColor('dark')
        selectionColor : colors.getColor('light')

        font.pointSize: parent.fontSize

        function acceptData() {
            if( !itemtime.text || itemtime.text == "") {
                model.duration = 0
            } else{ model.duration = itemtime.text * 60 }
        }

        onTextChanged: { acceptData() }
        onAccepted: { acceptData(); itemtime.text = model.duration / 60}
        onFocusChanged: { acceptData(); itemtime.text = model.duration / 60 }
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
        renderType: Text.NativeRendering

    }

    ColorSelector {
        id: colorSelector
        anchors.leftMargin: 0
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


