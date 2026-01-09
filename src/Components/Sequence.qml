import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "Sequence"
import ".."


Item {
    id: sequence

    property bool blockEdits: globalTimer.duration || globalTimer.running || pomodoroQueue.count > 0
    property bool showQueue: true

    function setCurrentItem(id){
        if(id === undefined){ id = -1 }
        sequenceView.currentIndex = id
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

        MouseArea {
            id: sequenceHoverArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true
        }

        Timer {
            id: scrollLinger
            interval: 1500
            repeat: false
        }

        ListView {
            id: sequenceView
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
                viewContainsMouse: sequenceHover.hovered
                    || sequenceHoverArea.containsMouse
                    || sequenceView.moving
                    || scrollLinger.running
            }

            property int itemWidth: width
            property int itemHeight: 38
            property bool draggingItem: false
            property real lastMouseY: -1
            property int edgeScrollDirection: 0
            property int edgeScrollThreshold: 24
            property int edgeScrollStep: 6
            function updateEdgeScroll(y) {
                lastMouseY = y
                if (y < edgeScrollThreshold) {
                    edgeScrollDirection = -1
                } else if (y > height - edgeScrollThreshold) {
                    edgeScrollDirection = 1
                } else {
                    edgeScrollDirection = 0
                }
            }

            model: masterModel

            onMovingChanged: {
                if (moving) {
                    scrollLinger.restart()
                }
            }

            onContentYChanged: scrollLinger.restart()

            Timer {
                id: autoScrollTimer
                interval: 16
                repeat: true
                running: sequenceView.draggingItem && sequenceView.edgeScrollDirection !== 0

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

            delegate: Item {
                id: delegateItem

                width: sequenceView.itemWidth
                height: sequenceView.itemHeight

                SequenceItem {id: sequenceItem }
                property bool dragActive: sequenceItem.Drag.active
                onDragActiveChanged: sequenceView.draggingItem = dragActive

                DropArea {
                    anchors.fill: parent
                    keys: ["sequenceItems"]
                    onEntered: (drag) => {
                        var draggedId = drag.source.dragItemIndex
                        masterModel.move(draggedId, index, 1)
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
    }
}
