import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "Sequence"

Item {
    id: sequence

    function setCurrentItem(id) {
        if (id === undefined) {
            id = -1
        }
        sequenceView.currentIndex = id
    }

    ListView {
        id: sequenceView

        anchors.top: parent.top
        anchors.bottom: sequenceToolbar.top
        anchors.left: parent.left
        anchors.right: parent.right

        width: parent.width
        spacing: 0
        clip: true
        orientation: ListView.Vertical
        snapMode: ListView.SnapToItem
        currentIndex: -1

        model: timerModel

        delegate: Item {
            id: delegateItem

            width: parent ? parent.width : 0
            height: 32

            SequenceItem {
                id: sequenceItem
            }

            DropArea {
                anchors.fill: parent
                keys: ["sequenceItems"]
                onEntered: (drag) => {
                    let draggedId = drag.source.dragItemIndex
                    timerModel.move(draggedId, index, 1)
                }
            }
        }

        addDisplaced: Transition {
            NumberAnimation {
                properties: "x, y"; duration: 100
            }
        }
        moveDisplaced: Transition {
            NumberAnimation {
                properties: "x, y"; duration: 100
            }
        }
        remove: Transition {
            NumberAnimation {
                properties: "x, y"; duration: 100
            }
            NumberAnimation {
                properties: "opacity"; duration: 100
            }
        }

        removeDisplaced: Transition {
            NumberAnimation {
                properties: "x, y"; duration: 100
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "x, y"; duration: 100
            }
        }
    }

    Toolbar {
        id: sequenceToolbar
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        z: 3
    }
}
