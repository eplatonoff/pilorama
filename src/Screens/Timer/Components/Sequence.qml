import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "Sequence"

Item {
    id: sequence

    property bool editable: false
    property int switchModeDuration: 150

    function setCurrentItem(id) {
        if (id === undefined) {
            id = -1;
        }
        sequenceView.currentIndex = id;
    }

    Header {
        id: sequenceHeader

        anchors.top: parent.top
        width: parent.width
    }
    ListView {
        id: sequenceView

        anchors.bottom: sequenceToolbar.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: sequenceHeader.bottom
        clip: true
        currentIndex: -1
        model: timerModel
        orientation: ListView.Vertical
        snapMode: ListView.SnapToItem
        spacing: 0
        width: parent.width

        addDisplaced: Transition {
            NumberAnimation {
                duration: 100
                properties: "x, y"
            }
        }
        delegate: Item {
            id: delegateItem

            height: 32
            width: parent ? parent.width : 0

            SequenceItem {
                id: sequenceItem

            }
            DropArea {
                anchors.fill: parent
                keys: ["sequenceItems"]

                onEntered: drag => {
                    let draggedId = drag.source.dragItemIndex;
                    timerModel.move(draggedId, index, 1);
                }
            }
        }
        displaced: Transition {
            NumberAnimation {
                duration: 100
                properties: "x, y"
            }
        }
        moveDisplaced: Transition {
            NumberAnimation {
                duration: 100
                properties: "x, y"
            }
        }
        remove: Transition {
            NumberAnimation {
                duration: 100
                properties: "x, y"
            }
            NumberAnimation {
                duration: 100
                properties: "opacity"
            }
        }
        removeDisplaced: Transition {
            NumberAnimation {
                duration: 100
                properties: "x, y"
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
