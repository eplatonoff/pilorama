import QtQuick 2.0
import QtGraphicalEffects 1.12

import "Sequence"

Item {
    id: startScreen
    visible: window.clockMode === "start"
    width: 150
    height: 150
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    property real headingFontSize: 23
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

//    Item {
//        id: start

//        width: 60
//        height: 60
//        anchors.bottom: presetName.top
//        anchors.bottomMargin: 5
//        anchors.horizontalCenter: parent.horizontalCenter

//        Image {
//            id: startIcon
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.bottom: totalTime.top
//            anchors.bottomMargin: 56
//            anchors.horizontalCenter: parent.horizontalCenter
//            sourceSize.height: 24
//            sourceSize.width: 24
//            antialiasing: true
//            visible: masterModel.count > 0 && masterModel.totalDuration() > 0
//            fillMode: Image.PreserveAspectFit
//            source: "../assets/img/play.svg"

//            ColorOverlay{
//                id: startOverlay
//                anchors.fill: parent
//                source: parent
//                color: colors.getColor("mid")
//                antialiasing: true
//            }
//        }

//        MouseArea {
//            id: startrigger
//            anchors.fill: parent
//            hoverEnabled: true
//            propagateComposedEvents: true
//            cursorShape: Qt.PointingHandCursor

//            onReleased: {
//                window.clockMode = "pomodoro"
//                pomodoroQueue.infiniteMode = true
//                globalTimer.start()

//            }
//        }
//    }




    Text {
        id: presetName
        text: masterModel.title
        anchors.top: parent.top
        anchors.topMargin: 45
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0

         layer.enabled: true
         wrapMode: TextEdit.NoWrap


         font.pointSize: startScreen.headingFontSize
         font.family: openSans.name
         renderType: Text.NativeRendering
         antialiasing: true

         color: colors.getColor("dark")

     }

    Text {
        id: totalTime
        color: colors.getColor('mid')
        text: "Total: " + masterModel.totalDuration() / 60 + " min"
        anchors.top: presetName.bottom
        anchors.topMargin: 6
        verticalAlignment: Text.AlignVCenter
        anchors.left: parent.left
        anchors.leftMargin: 0
        horizontalAlignment: Text.AlignHCenter
        anchors.right: parent.right
        anchors.rightMargin: 0
        font.pixelSize: startScreen.fontSize
    }


//    Row {
//        id: fileBlock
//        height: 24
//        anchors.top: parent.top
//        anchors.topMargin: 0
//        anchors.horizontalCenter: parent.horizontalCenter
//        spacing: 3


//        LoadButton {
//            id: loadButton
//            anchors.verticalCenter: parent.verticalCenter
//        }

//        SaveButton {
//            id: saveButton
//            anchors.verticalCenter: parent.verticalCenter
//        }

//    }

    ResetButton{
        id: play
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 7
        anchors.horizontalCenter: parent.horizontalCenter
        label: 'Start'

        MouseArea {
            id: playtrigger
            anchors.bottomMargin: 0
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


}

/*##^##
Designer {
    D{i:2;anchors_width:30}D{i:5;anchors_width:30}D{i:6;anchors_width:30}
}
##^##*/
