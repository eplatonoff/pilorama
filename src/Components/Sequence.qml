import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "Sequence"
import ".."


Item {
    id: sequence

    property bool blockEdits: globalTimer.remainingTime || globalTimer.running || pomodoroQueue.count > 0
    // Display the burner queue while the timer is running or while the
    // timer dial is being dragged in the non‑infinite "split to sequence"
    // mode.  This keeps the master model visible on startup and whenever the
    // timer is idle.
    readonly property bool queueMode: !pomodoroQueue.infiniteMode &&
                                      preferences.splitToSequence &&
                                      (globalTimer.running || mouseArea.dragging)


    function setCurrentItem(id){
        if(id === undefined){ id = -1 }
        if(queueMode){
            // Highlight the first queue item only when a valid segment index is
            // provided (i.e. while the timer is running).  When called with
            // -1 during a drag, clear the highlight.
            queueView.currentIndex = id >= 0 && pomodoroQueue.count > 0 ? 0 : -1
        } else {
            sequenceView.currentIndex = id
        }
    }


    Footer {
        id: sequenceFooter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        z: 3
    }

    Rectangle {
        id: sequenceSetLayout
        color: 'transparent'
        clip: false
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: sequenceFooter.top
        anchors.left: parent.left
        anchors.topMargin: 0

        HoverHandler {
            id: sequenceHover
        }

        ListView {
            id: sequenceView
            visible: !sequence.queueMode
            anchors.fill: parent
            spacing: 0
            orientation: ListView.Vertical
            clip: true
            snapMode: ListView.SnapToItem
            footerPositioning: ListView.OverlayFooter
            currentIndex: -1

            ScrollBar.vertical: TransparentScrollBar {
                parent: sequenceSetLayout
                x: sequenceSetLayout.width - width + 5
                y: sequenceView.y
                height: sequenceView.height
                width: implicitWidth
                viewContainsMouse: sequenceHover.hovered || sequenceView.moving
                visible: sequenceView.contentHeight > sequenceView.height
            }

            property int itemWidth: width
            property int itemHeight: 38
            property bool isDragging: false
            property var dragSource: null
            property var openColorSelector: null
            property int edgeScrollDirection: 0
            property int edgeScrollThreshold: 24
            property int edgeScrollStep: 6
            function closeOpenColorSelector() {
                if (openColorSelector) {
                    openColorSelector.expanded = false
                }
            }
            function setEdgeScrollDirection(y) {
                if (y < edgeScrollThreshold) {
                    edgeScrollDirection = -1
                } else if (y > height - edgeScrollThreshold) {
                    edgeScrollDirection = 1
                } else {
                    edgeScrollDirection = 0
                }
            }

            model: masterModel

            Timer {
                id: autoScrollTimer
                interval: 16
                repeat: true
                running: sequenceView.isDragging
                    && sequenceView.edgeScrollDirection !== 0
                    && sequenceView.contentHeight > sequenceView.height

                onTriggered: {
                    const maxY = Math.max(0, sequenceView.contentHeight - sequenceView.height)
                    if (maxY === 0) {
                        return
                    }
                    const nextY = sequenceView.contentY
                        + (sequenceView.edgeScrollDirection * sequenceView.edgeScrollStep)
                    sequenceView.contentY = Math.max(0, Math.min(maxY, nextY))
                }
            }

            delegate: masterDelegate

            TapHandler {
                enabled: sequenceView.openColorSelector !== null
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onTapped: (eventPoint, button) => {
                    const selector = sequenceView.openColorSelector
                    if (!selector) {
                        return
                    }
                    const local = selector.mapFromItem(
                        sequenceView,
                        eventPoint.position.x,
                        eventPoint.position.y)
                    const inside = local.x >= 0
                        && local.x <= selector.width
                        && local.y >= 0
                        && local.y <= selector.height
                    if (!inside) {
                        selector.expanded = false
                    }
                }
            }

            addDisplaced: Transition {
                NumberAnimation {properties: "x, y"; duration: 100}
            }
            moveDisplaced: Transition {
                NumberAnimation { properties: "x, y"; duration: 100 }
            }
            remove: Transition {
                NumberAnimation { properties: "x, y"; duration: 100 }
                NumberAnimation { properties: "opacity"; duration: 100}
            }

            removeDisplaced: Transition {
                NumberAnimation { properties: "x, y"; duration: 100 }
            }

            displaced: Transition {
                NumberAnimation {properties: "x, y"; duration: 100}
            }
        }

        ListView {
            id: queueView
            visible: sequence.queueMode
            anchors.fill: parent
            spacing: 0
            orientation: ListView.Vertical
            clip: true
            snapMode: ListView.SnapToItem
            footerPositioning: ListView.OverlayFooter
            currentIndex: -1

            property int itemWidth: width
            property int itemHeight: 38

            model: pomodoroQueue

            delegate: queueDelegate

            addDisplaced: Transition {
                NumberAnimation {properties: "x, y"; duration: 100}
            }
            moveDisplaced: Transition {
                NumberAnimation { properties: "x, y"; duration: 100 }
            }
            remove: Transition {
                NumberAnimation { properties: "x, y"; duration: 100 }
                NumberAnimation { properties: "opacity"; duration: 100}
            }

            removeDisplaced: Transition {
                NumberAnimation { properties: "x, y"; duration: 100 }
            }

            displaced: Transition {
                NumberAnimation {properties: "x, y"; duration: 100}
            }
        }

        Component {
            id: masterDelegate
            Item {
                id: delegateItem
                width: sequenceView.itemWidth
                height: sequenceView.itemHeight

                SequenceItem { id: sequenceItem }
                property bool dragActive: sequenceItem.Drag.active
                onDragActiveChanged: {
                    if (dragActive) {
                        sequenceView.dragSource = sequenceItem
                        sequenceView.isDragging = true
                    } else if (sequenceView.dragSource === sequenceItem) {
                        sequenceView.dragSource = null
                        sequenceView.isDragging = false
                    }
                }

                DropArea {
                    anchors.fill: parent
                    keys: ["sequenceItems"]
                    onEntered: (drag) => {
                        var draggedId = drag.source.dragItemIndex
                        masterModel.move(draggedId, index, 1)
                    }
                }
            }
        }

        Component {
            id: queueDelegate
            Rectangle {
                id: queueItem
                width: queueView.itemWidth
                height: queueView.itemHeight
                color: colors.getColor('bg')

                // Highlight the active queue item while always displaying the
                // entire sequence during a split run.
                visible: true

                property var masterItem: masterModel.get(model.id)
                property bool currentItem: queueItem.ListView.isCurrentItem

                Rectangle {
                    id: colorIndicator
                    width: 13
                    height: 13
                    radius: 30
                    color: colors.getColor(masterItem.color)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }

                Timer {
                    id: blinkTimer
                    interval: 500
                    repeat: true
                    running: false
                    onTriggered: colorIndicator.opacity = colorIndicator.opacity ? 0 : 1
                }

                Connections {
                    target: globalTimer
                    function onRunningChanged(running) {
                        blinkTimer.running = running && sequence.queueMode && currentItem && masterItem.duration !== 0
                        if (!blinkTimer.running)
                            colorIndicator.opacity = 1
                    }
                }

                Connections {
                    target: sequence
                    function onQueueModeChanged() {
                        blinkTimer.running = globalTimer.running && sequence.queueMode && currentItem && masterItem.duration !== 0
                        if (!blinkTimer.running)
                            colorIndicator.opacity = 1
                    }
                }

                Component.onCompleted: {
                    blinkTimer.running = globalTimer.running && sequence.queueMode && currentItem && masterItem.duration !== 0
                }

                onCurrentItemChanged: {
                    blinkTimer.running = globalTimer.running && sequence.queueMode && currentItem && masterItem.duration !== 0
                    if (!blinkTimer.running)
                        colorIndicator.opacity = 1
                }

                Text {
                    text: masterItem.name
                    anchors.left: parent.left
                    anchors.leftMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: localFont.name
                    font.pixelSize: 14
                    color: colors.getColor('dark')
                    renderType: Text.NativeRendering
                }

                Text {
                    // Round up to avoid an instant one-minute drop when the
                    // timer starts and seconds decrease from a whole minute
                    // value like 300 to 299. This keeps the displayed minutes
                    // consistent with the dial until an entire minute elapses.
                    text: Math.ceil(model.duration / 60)
                    anchors.right: qMin.left
                    anchors.rightMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: localFont.name
                    font.pixelSize: 14
                    color: colors.getColor('dark')
                    renderType: Text.NativeRendering
                }

                Text {
                    id: qMin
                    width: 30
                    text: qsTr("min")
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: localFont.name
                    font.pixelSize: 14
                    color: colors.getColor('mid')
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
