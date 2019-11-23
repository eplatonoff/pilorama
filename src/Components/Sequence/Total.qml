import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: total
    height: 60
    width: parent.width

    property real fontSize: 14

    function getSequenceTime(){
        let time = 0
        for(var i = 0; i<masterModel.count; i++){
           time += masterModel.get(i).duration / 60
        }
        return time
    }

    Rectangle{
        anchors.fill: parent
        color: colors.getColor("bg")
    }

//    Rectangle {
//        id: totalDivider
//        height: 1
//        width: parent.width
//        color: colors.getColor("light")
//        anchors.topMargin: 8
//        anchors.top: parent.top

//    }

    Image {
        id: countdownIcon
        source: "../../assets/img/countdown.svg"
        fillMode: Image.PreserveAspectFit

        property bool prefsToggle: false
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter

        ColorOverlay{
            id: countdownIconOverlay
            anchors.fill: parent
            source: parent
            color: colors.getColor('light')
            antialiasing: true
        }
    }

    Text {
        id: totalName
        text: "Sequence countdown:"
        anchors.leftMargin: 10
        anchors.left: countdownIcon.right
        horizontalAlignment: Text.AlignLeft
        font.pixelSize: parent.fontSize
        color: colors.getColor('mid')
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: totalTime
        width: 30
        color: colors.getColor('mid')
        text: parent.getSequenceTime()
        horizontalAlignment: Text.AlignRight
        anchors.right: itemtimeMin.left
        anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: parent.fontSize
    }

    Text {
        id: itemtimeMin
        width: 30
        text: qsTr("min")
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor('mid')
        font.pixelSize: parent.fontSize
    }

}
