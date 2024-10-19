import QtQuick
import QtQuick.Controls

import "../../../../Components"

Item {
    id: sequenceItem

    property bool currentItem: delegateItem.ListView.isCurrentItem
    property int dragItemIndex: index
    property real fontSize: 14

    Drag.active: itemDragTrigger.drag.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
    Drag.keys: ["sequenceItems"]
    height: 32
    width: parent.width

    states: [
        State {
            when: sequenceItem.Drag.active

            ParentChange {
                parent: sequenceView
                target: sequenceItem
            }
            AnchorChanges {
                anchors.verticalCenter: undefined
                target: sequenceItem
            }
        }
    ]

    FaIcon {
        id: dragHandler

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        color: colors.getColor('lighter')
        glyph: "\uf0dc"
        size: 12
        width: sequence.editable ? 12 : 0

        Behavior on width {
            NumberAnimation {
                duration: sequence.switchModeDuration
            }
        }
    }
    MouseArea {
        id: itemDragTrigger

        ToolTip.delay: 500
        ToolTip.text: "Drag to reorder"
        ToolTip.visible: containsMouse
        anchors.fill: dragHandler
        anchors.margins: -2
        cursorShape: containsPress ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        drag.target: sequenceItem
        hoverEnabled: true
        propagateComposedEvents: true

        onPressAndHold: {
            if (itemDragTrigger.drag.active) {
                sequenceItem.dragItemIndex = index;
            }
        }
    }
    TextInput {
        id: itemName

        anchors.left: dragHandler.right
        anchors.leftMargin: 26
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('dark')
        font.family: localFont.name
        font.pixelSize: parent.fontSize
        horizontalAlignment: Text.AlignLeft
        readOnly: !sequence.editable
        renderType: Text.NativeRendering
        selectByMouse: sequence.editable
        selectedTextColor: colors.getColor('dark')
        selectionColor: colors.getColor('lighter')
        text: model.name
        width: parent.width - 20
        wrapMode: TextEdit.NoWrap

        onEditingFinished: {
            model.name = itemName.text;
        }
    }
    TextInput {
        id: itemTime

        anchors.right: timeLabel.left
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('mid')
        font.family: localFont.name
        font.pixelSize: parent.fontSize
        horizontalAlignment: Text.AlignRight
        inputMethodHints: Qt.ImhDigitsOnly
        readOnly: !sequence.editable
        renderType: Text.NativeRendering
        selectByMouse: sequence.editable
        text: Math.trunc(model.duration / 60)
        wrapMode: TextEdit.NoWrap

        validator: IntValidator {
            bottom: 1
            top: globalTimer.timerLimit / 60
        }

        onActiveFocusChanged: {
            if (!itemTime.acceptableInput) {
                model.duration = 0;
            }
        }
        onEditingFinished: {
            model.duration = itemTime.text * 60;
        }
    }
    Text {
        id: timeLabel

        anchors.right: itemControls.left
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('mid')
        font.family: localFont.name
        font.pixelSize: parent.fontSize
        renderType: Text.NativeRendering
        text: "′"
    }
    Item {
        id: itemControls

        anchors.right: parent.right
        clip: true
        height: parent.height
        width: sequence.editable ? 40 : 0

        Behavior on width {
            NumberAnimation {
                duration: sequence.switchModeDuration
            }
        }

        FaIcon {
            id: removeButton

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor('light')
            glyph: "\uf00d"
            size: 14
            tooltip: "Remove"

            onReleased: {
                timerModel.remove(index);
            }
        }
        FaIcon {
            id: copyButton

            anchors.right: removeButton.left
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor('light')
            glyph: "\uf0c5"
            size: 14
            tooltip: "Duplicate"

            onReleased: {
                timerModel.add(model.name, model.color, model.duration);
            }
        }
    }
    ColorSelector {
        id: colorSelector

        anchors.left: dragHandler.right
        anchors.verticalCenter: parent.verticalCenter
        itemIndex: index
    }
}
