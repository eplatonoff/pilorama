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
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: sequenceFooter.top
        anchors.left: parent.left
        anchors.topMargin: 0

        ListView {
            id: sequenceView
            anchors.fill: parent
            spacing: 0
            orientation: ListView.Vertical
            clip: true
            snapMode: ListView.SnapToItem
            footerPositioning: ListView.OverlayFooter
            currentIndex: -1

            property int itemWidth: width
            property int itemHeight: 38

            model: masterModel

            delegate: Item {
                id: delegateItem

                width: sequenceView.itemWidth
                height: sequenceView.itemHeight

                SequenceItem {id: sequenceItem }

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
