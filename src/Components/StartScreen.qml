import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: element
    visible: window.clockMode === "start"
    width: 200
    height: 200
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    property real headingFontSize: 20
    property real fontSize: 14

//    Image {
//        id: startPomoBG
//        anchors.horizontalCenter: parent.horizontalCenter
//        sourceSize.height: 200
//        sourceSize.width: 200
//        antialiasing: true
//        visible: masterModel.count > 0 && masterModel.totalDuration() > 0
//        anchors.verticalCenter: parent.verticalCenter
//        fillMode: Image.PreserveAspectFit
//        source: "../assets/img/background.svg"

//        ColorOverlay{
//            id: startPomoBGOverlay
//            anchors.fill: parent
//            source: parent
//            color: colors.getColor("light")
//            antialiasing: true
//        }
//    }

    Image {
        id: startPomoIcon
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.height: 150
        sourceSize.width: 150
        antialiasing: true
        visible: masterModel.count > 0 && masterModel.totalDuration() > 0
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "../assets/img/play.svg"

        ColorOverlay{
            id: startPomoOverlay
            anchors.fill: parent
            source: parent
            color: colors.getColor("mid")
            antialiasing: true
        }

        MouseArea {
            id: startPomoTrigger
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            cursorShape: Qt.PointingHandCursor

            onReleased: {
                window.clockMode = "pomodoro"
                pomodoroQueue.infiniteMode = true
                globalTimer.start()

            }
        }
    }

    Text {
        id: presetName
        text: masterModel.title
        horizontalAlignment: Text.AlignHCenter
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: totalTime.top
        anchors.bottomMargin: 7

        layer.enabled: true
        wrapMode: TextEdit.NoWrap


        font.pointSize: parent.headingFontSize
        font.family: openSans.name
        renderType: Text.NativeRendering
        antialiasing: true

        color: colors.getColor("dark")

    }


        Text {
            id: totalTime
            color: colors.getColor('mid')
            text: masterModel.totalDuration() / 60 + " min"
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            horizontalAlignment: Text.AlignHCenter
            anchors.right: parent.right
            anchors.rightMargin: 0
            font.pixelSize: fontSize
        }

//        Text {
//            id: itemtimeMin
//            width: 30
//            text: qsTr("min")
//            anchors.right: parent.right
//            anchors.verticalCenter: parent.verticalCenter
//            color: colors.getColor('mid')
//            font.pixelSize: fontSize
//        }


}

/*##^##
Designer {
    D{i:5;anchors_width:30}
}
##^##*/
