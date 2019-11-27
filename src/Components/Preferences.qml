import QtQuick 2.0

import "Preferences"

Item {
    id: preferences
    visible: false

    property bool splitToSequence: false
    property int fontSize: 16
    property int infoFontSize: 12

    Header {
        id: prefsHeader
    }

    Column {

        id: prefs

        spacing: 7

        property real dotSize: 10
        property real dotSpacing: 3
        property real cellHeight: 19
        anchors.top: prefsHeader.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        anchors.topMargin: 0

        Item {
            id: splitToSequence
            height: parent.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Text {
                id: splitToSequenceLabel
                width: 115
                height: 19
                text: qsTr("Split timer to sequence:")
                color: colors.getColor("mid")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 0
                font.pixelSize: fontSize
            }

            Text {
                id: splitToSequenceSetting
                width: 30
                color: colors.getColor("dark")
                text:  preferences.splitToSequence
                anchors.right: parent.right
                anchors.rightMargin: 0
                horizontalAlignment: Text.AlignLeft
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: fontSize
            }

            MouseArea {
                id: splitToSequenceTrigger
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    preferences.splitToSequence = !preferences.splitToSequence
                }
            }
        }

        Item {
            id: onTop
            height: parent.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Text {
                id: onTopLabel
                width: 115
                height: 19
                text: qsTr("Always on top:")
                color: colors.getColor("mid")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 0
                font.pixelSize: fontSize
            }

            Text {
                id: onTopSetting
                width: 30
                color: colors.getColor("dark")
                text: window.alwaysOnTop
                anchors.right: parent.right
                anchors.rightMargin: 0
                horizontalAlignment: Text.AlignLeft
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: fontSize
            }

            MouseArea {
                id: onTopTrigger
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    window.alwaysOnTop = !window.alwaysOnTop
                }
            }
        }

    }

    Text {
        id: help
        text: '<html><a href="https://github.com/eplatonoff/qml-timer">project on github</a></html>'
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: infoFontSize

        onLinkActivated: Qt.openUrlExternally(link)

    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
