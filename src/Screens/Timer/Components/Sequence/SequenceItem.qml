import QtQuick

import "../../../../Components"

Item {
    id: sequenceItem
    width: parent.width
    height: 32

    property real fontSize: 14
    property int dragItemIndex: index
    property bool currentItem: delegateItem.ListView.isCurrentItem

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
        anchors.leftMargin: 26
        anchors.verticalCenter: parent.verticalCenter

        layer.enabled: true
        wrapMode: TextEdit.NoWrap

        font.family: localFont.name
        font.pixelSize: parent.fontSize
        color: colors.getColor('dark')

        renderType: Text.NativeRendering

        selectedTextColor: colors.getColor('dark')
        selectionColor: colors.getColor('lighter')

        onEditingFinished: { model.name = itemName.text }
    }

    TextInput {
        id: itemTime
        color: colors.getColor('mid')
        text: Math.trunc( model.duration / 60 )

        validator: IntValidator { bottom: 1; top: globalTimer.timerLimit / 60}
        inputMethodHints: Qt.ImhDigitsOnly

        wrapMode: TextEdit.NoWrap
        renderType: Text.NativeRendering

        horizontalAlignment: Text.AlignRight
        anchors.right: timeLabel.left
        anchors.verticalCenter: parent.verticalCenter

        selectedTextColor : colors.getColor('dark')
        selectionColor : colors.getColor('lighter')

        font.family: localFont.name
        font.pixelSize: parent.fontSize

        onActiveFocusChanged: {
            if (!itemTime.acceptableInput) {
                model.duration = 0
            }
        }

        onEditingFinished: {
            model.duration = itemTime.text * 60
        }
    }

    Text {
        id: timeLabel
        text: "′"
        anchors.right: itemControls.left
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('mid')

        font.family: localFont.name
        font.pixelSize: parent.fontSize

        renderType: Text.NativeRendering

    }


    Item {
        id: itemControls

        height: parent.height
        width: 40
        anchors.right: parent.right

        FaIcon {
            id: closeButton
            glyph: "\uf00d"
            size: 14
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            color: colors.getColor('light')

            onReleased: {
                timerModel.remove(index)
            }
        }

        FaIcon {
            id: copyButton
            glyph: "\uf0c5"
            size: 14
            anchors.right: closeButton.left
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor('light')

            onReleased: {
                timerModel.add(model.name, model.color, model.duration)
            }
        }
    }

    ColorSelector {
        id: colorSelector
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: dragHandler.right
        itemIndex: index
    }
}
