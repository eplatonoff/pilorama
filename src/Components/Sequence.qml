import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.1

import "Sequence"
import ".."


Item {
    id: sequence

    property bool hlight: false

    Rectangle {
        id: layoutDivider
        height: 1
        width: parent.width
        color: colors.getColor("light")
        anchors.topMargin: padding
        anchors.top: parent.top

        property real padding: 18

    }

    Header {
        id: sequenceHeader
        anchors.top: layoutDivider.bottom
    }

    Rectangle {
        id: sequenceSetLayout
        color: colors.getColor("bg")
        anchors.bottomMargin: 0
        anchors.top: sequenceHeader.bottom
        anchors.right: parent.right
        anchors.bottom: tools.top
        anchors.left: parent.left
        anchors.topMargin: 0

        ListView {
            id: sequenceView
            anchors.fill: parent
            spacing: 0
            orientation: ListView.Vertical
            clip: true

            property int itemWidth: width
            property int itemHeight: 38

            model: masterModel

            delegate: Item {
                id: delegateItem

                width: sequenceView.itemWidth
                height: sequenceView.itemHeight

                SequenceItem {id: sequenceItem}

                DropArea {
                    anchors.fill: parent
                    onEntered: {
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


    Tools {
        id: tools
    }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
