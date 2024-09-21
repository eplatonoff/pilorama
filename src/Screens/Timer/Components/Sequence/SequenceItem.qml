import QtQuick

import "../../../../Components"

Item {
    id: sequenceItem
    width: parent.width
    height: 32

    property real fontSize: 14
    property int dragItemIndex: index
    property bool currentItem: delegateItem.ListView.isCurrentItem

    // property bool splitToSequence: preferences.splitToSequence

    // function dimmer() {
    //     const color = colors.getColor('dark')
    //     const dimColor = colors.getColor('mid')
    //
    //      if (!pomodoroQueue.infiniteMode && !splitToSequence && globalTimer.duration){
    //         return dimColor
    //     } else if (model.duration === 0){
    //         return dimColor
    //     } else {
    //         return color
    //     }
    // }

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

    FaIcon {
        id: dragHandler
        glyph: "\uf0dc"
        // visible: !sequence.blockEdits
        // width: sequence.blockEdits ? 0 : 24
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        size: 12

        color: colors.getColor('lighter')
    }

    MouseArea {
        id: itemDragTrigger
        anchors.fill: dragHandler

        hoverEnabled: true
        propagateComposedEvents: true

        drag.target: sequenceItem

        onPressAndHold: {
            if (itemDragTrigger.drag.active) {
                sequenceItem.dragItemIndex = index;
            }
        }
    }

    TextInput {
        id: itemName
        width: parent.width - 20
        text: model.name
        horizontalAlignment: Text.AlignLeft
        anchors.left: dragHandler.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        layer.enabled: true
        wrapMode: TextEdit.NoWrap
        // readOnly: sequence.blockEdits
        // selectByMouse: !sequence.blockEdits

        font.family: localFont.name
        font.pixelSize: parent.fontSize
        color: colors.getColor("dark")

        renderType: Text.NativeRendering

        selectedTextColor: colors.getColor('dark')
        selectionColor: colors.getColor('lighter')

        // color: sequenceItem.dimmer()

        onEditingFinished: { model.name = itemName.text }
    }

    // TextInput {
    //     id: itemtime
    //     width: 20
    //     color: sequenceItem.dimmer()
    //     text: Math.trunc( model.duration / 60 )
    //
    //     validator: IntValidator { bottom: 1; top: globalTimer.timerLimit / 60}
    //     inputMethodHints: Qt.ImhDigitsOnly
    //
    //     wrapMode: TextEdit.NoWrap
    //     readOnly: sequence.blockEdits
    //     selectByMouse : !sequence.blockEdits
    //     renderType: Text.NativeRendering
    //
    //
    //     horizontalAlignment: Text.AlignRight
    //     anchors.right: itemtimeMin.left
    //     anchors.rightMargin: 18
    //     anchors.verticalCenter: parent.verticalCenter
    //
    //     selectedTextColor : colors.getColor('dark')
    //     selectionColor : colors.getColor('lighter')
    //
    //     font.family: localFont.name
    //     font.pixelSize: parent.fontSize
    //
    //     onActiveFocusChanged: {
    //         if (!itemtime.acceptableInput) {
    //             model.duration = 0
    //         }
    //     }
    //
    //     onEditingFinished: {
    //         model.duration = itemtime.text * 60
    //     }
    // }
    //
    // Text {
    //     id: itemtimeMin
    //     width: 30
    //     text: qsTr("min")
    //     anchors.right: parent.right
    //     anchors.verticalCenter: parent.verticalCenter
    //     color: colors.getColor('mid')
    //
    //     font.family: localFont.name
    //     font.pixelSize: parent.fontSize
    //
    //     renderType: Text.NativeRendering
    //
    // }
    //
    // ColorSelector {
    //     id: colorSelector
    //     anchors.verticalCenter: parent.verticalCenter
    //     anchors.left: handler.right
    //     lineId: index
    //
    // }
    //
    // Rectangle {
    //     id: itemControls
    //     visible: false
    //     color: colors.getColor("bg")
    //
    //     height: parent.height
    //     width: 0
    //
    //     Behavior on width { PropertyAnimation { duration: 100 } }
    //
    //     anchors.right: parent.right
    //
    //     Icon {
    //         id: closeButton
    //         glyph: "\uea0f"
    //         anchors.right: parent.right
    //         anchors.verticalCenter: parent.verticalCenter
    //         color: colors.getColor('light')
    //
    //         onReleased: {
    //             globalTimer.stop()
    //             masterModel.remove(index)
    //         }
    //     }
    //
    //     Icon {
    //         id: copyButton
    //         glyph: "\uea0e"
    //         anchors.left: parent.left
    //         anchors.verticalCenter: parent.verticalCenter
    //         color: colors.getColor('light')
    //
    //         onReleased: {
    //             masterModel.add(model.name, model.color, model.duration)
    //         }
    //     }
    //
    //
    // }
}
