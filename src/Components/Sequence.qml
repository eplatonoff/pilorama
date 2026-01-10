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
                viewContainsMouse: sequenceHover.hovered || sequenceView.moving
            }

            property int itemWidth: width
            property int itemHeight: 38
            property bool isDragging: false
            property var dragSource: null
            property int edgeScrollDirection: 0
            property int edgeScrollThreshold: 24
            property int edgeScrollStep: 6
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

            delegate: Item {
                id: delegateItem

                width: sequenceView.itemWidth
                height: sequenceView.itemHeight

                SequenceItem {id: sequenceItem }
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
