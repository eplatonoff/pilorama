import QtQuick
import ".."

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

    Icon {
        id: handler
        glyph: "\uea0d"
        visible: !sequence.blockEdits
        width: sequence.blockEdits ? 0 : 24
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        propagateComposedEvents: false

        color: colors.getColor('lighter')


        Behavior on width { NumberAnimation { properties: "width"; duration: 150 }}

    }

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


    TextInput {
        id: itemName
        width: 170
        text: model.name
        horizontalAlignment: Text.AlignLeft
        anchors.left: handler.right
        anchors.leftMargin: 26

        layer.enabled: true
        wrapMode: TextEdit.NoWrap
        readOnly: sequence.blockEdits
        selectByMouse : !sequence.blockEdits

        font.family: localFont.name
        font.pixelSize: parent.fontSize

        renderType: Text.NativeRendering


        selectedTextColor : colors.getColor('dark')
        selectionColor : colors.getColor('lighter')

        color: sequenceItem.dimmer()
        anchors.verticalCenter: parent.verticalCenter

        onEditingFinished: { model.name = itemName.text }
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
        selectionColor : colors.getColor('lighter')

        font.family: localFont.name
        font.pixelSize: parent.fontSize

        onActiveFocusChanged: {
            if (!itemtime.acceptableInput) {
                model.duration = 0
            }
        }

        onAcceptableInputChanged: {
            if (itemtime.acceptableInput) {
                model.duration = Number(itemtime.text) * 60
            } else {
                model.duration = 0
            }
        }
    }

    Text {
        id: itemtimeMin
        width: 30
        text: qsTr("min")
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('mid')

        font.family: localFont.name
        font.pixelSize: parent.fontSize

        renderType: Text.NativeRendering

    }

    ColorSelector {
        id: colorSelector
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

        Icon {
            id: closeButton
            glyph: "\uea0f"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor('light')

            onReleased: {
                globalTimer.stop()
                masterModel.remove(index)
            }
        }

        Icon {
            id: copyButton
            glyph: "\uea0e"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor('light')

            onReleased: {
                masterModel.add(model.name, model.color, model.duration)
            }
        }


    }
}


