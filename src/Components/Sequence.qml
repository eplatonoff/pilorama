import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.1

import "Sequence"
import ".."


Item {
    id: sequence
    height: layoutDivider.height + layoutDivider.padding + sequenceHeader.height + sequenceSetLayout.height + total.height + tools.height
    width: parent.width
//    anchors.top: parent.top
//    anchors.bottom: parent.bottom


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
        height: (masterModel.count + 0)  * 38
        width: parent.width
        color: colors.getColor("bg")
        anchors.top: sequenceHeader.bottom

        ListView {
            id: sequenceSet
            anchors.fill: parent
            spacing: 0
            cacheBuffer: 40
            snapMode: ListView.SnapOneItem
            model: masterModel
            delegate: SequenceItem { id: sequenceItem; }
        }
    }

    Total {
        id: total
        anchors.top: sequenceSetLayout.bottom
        anchors.topMargin: 0
    }

    Tools {
        id: tools
    }
}


