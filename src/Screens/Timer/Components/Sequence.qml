import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "Sequence"

Item {
    id: sequence

    // property bool blockEdits: globalTimer.duration || globalTimer.running
    // property bool showQueue: true

    function setCurrentItem(id) {
        if (id === undefined) {
            id = -1
        }
        sequenceView.currentIndex = id
    }


    // Footer {
    //     id: sequenceFooter
    //     anchors.bottom: parent.bottom
    //     anchors.bottomMargin: 0
    //     z: 3
    // }


    ListView {
        id: sequenceView
        anchors.fill: parent
        spacing: 0
        clip: true
        orientation: ListView.Vertical
        snapMode: ListView.SnapToItem
        currentIndex: -1

        model: timerModel

        delegate: Item {
            id: delegateItem

            width: parent.width
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
}
