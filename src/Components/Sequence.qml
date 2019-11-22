import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.1

import "Sequence"
import ".."


Item {
    id: sequence
    height: sequenceHeader.height + sequenceSetLayout.height + tools.height
    width: parent.width

    Rectangle {
        id: sequenceSetLayout
        height: (masterModel.count + 1)  * 38
        width: parent.width
        color: colors.getColor("bg")
        anchors.top: sequenceHeader.bottom

//        DelegateModel {
//            id: visualModel
//            model: SequenceModel{ id: sequenceModel }
//            delegate: SequenceItem { id: sequenceItem }
//            }



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

    Header {
        id: sequenceHeader
    }

    Tools {
        id: tools
    }
//    ExternalDrop {
//        id: externalDrop
//    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
