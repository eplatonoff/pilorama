import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.1
import QtQml.Models 2.13

import "Sequence"


Item {
    id: sequence

    SequenceModel {
        id: sequenceModel
    }

    Rectangle {

        color: colors.get()
//        Behavior on color { ColorAnimation { duration: 100 } }

        anchors.top: sequenceHeader.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.topMargin: 5
        anchors.bottomMargin: 45

        ListView {
            id: sequenceSet
            anchors.fill: parent
            spacing: 0
            cacheBuffer: 50
            orientation: ListView.Vertical
            model: sequenceModel
            delegate: SequenceItem {
            }
        }
    }

    Header {
        id: sequenceHeader
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
    }

    Tools {
        id: tools
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
