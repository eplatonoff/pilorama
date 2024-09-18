import QtQuick
import QtQuick.Controls

import "Components"
import "../../Components"

Item {
    id: preferences
    visible: false

    property bool splitToSequence: false

    property int cellHeight: 38

    property int fontSize: 14
    property int infoFontSize: 12

    

        Header {
            id: prefsHeader
        }

    Column {

        id: prefs

        spacing: 0



        anchors.top: prefsHeader.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        anchors.margins: 16

        Item {
            id: splitToSequence
            height: preferences.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Checkbox {
                id: splitToSequenceCheck
                checked: preferences.splitToSequence
            }

            Text {
                id: splitToSequenceLabel
                height: 19
                text: qsTr("Split timer to sequence")
                anchors.right: parent.right
                anchors.rightMargin: 0
                color: colors.getColor("dark")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: splitToSequenceCheck.right
                anchors.leftMargin: 0

                font.family: localFont.name
                font.pixelSize: fontSize

                renderType: Text.NativeRendering

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
            height: preferences.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Checkbox {
                id: onTopCheck
                checked: window.alwaysOnTop
            }

            Text {
                id: onTopLabel
                height: 19
                text: qsTr("Always on top")
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: onTopCheck.right
                anchors.leftMargin: 0
                color: colors.getColor("dark")
                anchors.verticalCenter: parent.verticalCenter

                font.family: localFont.name
                font.pixelSize: fontSize

                renderType: Text.NativeRendering

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

        Item {
            id: closeOnQuit
            height: preferences.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Checkbox {
                id: closeOnQuitCheck
                checked: !window.quitOnClose
            }

            Text {
                id: closeOnQuitLabel
                height: 19
                text: qsTr("On close hide to system tray")
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: closeOnQuitCheck.right
                anchors.leftMargin: 0
                color: colors.getColor("dark")
                anchors.verticalCenter: parent.verticalCenter

                font.family: localFont.name
                font.pixelSize: fontSize

                renderType: Text.NativeRendering

            }


            MouseArea {
                id: closeOnQuitTrigger
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    window.quitOnClose = !window.quitOnClose
                }
            }
        }

        Item {
            visible: Qt.platform.os === "osx"

            id: showInDock
            height: preferences.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Checkbox {
                id: showInDockCheck
                checked: appSettings.showInDock
            }

            Text {
                id: showInDockLabel
                height: 19
                text: qsTr("Show app in Dock")
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: showInDockCheck.right
                anchors.leftMargin: 0
                color: colors.getColor("dark")
                anchors.verticalCenter: parent.verticalCenter

                font.family: localFont.name
                font.pixelSize: fontSize

                renderType: Text.NativeRendering
            }

            MouseArea {
                id: showInDockCheckTrigger
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    appSettings.showInDock = !appSettings.showInDock
                }
            }
        }
        
        Item {
            id: colorTheme
            height: preferences.cellHeight
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Text {
                id: colorThemeLabel
                height: 19
                text: qsTr("Color theme")
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                color: colors.getColor("dark")

                font.family: localFont.name
                font.pixelSize: fontSize

                renderType: Text.NativeRendering
            }

            ComboBox {
                id: colorThemeCombo
                model: ["Light", "Dark", "System"]
                currentIndex: {
                    const index = colorThemeCombo.model.indexOf(appSettings.colorTheme);
                    return index !== -1 ? index : 0;
                }
                anchors.left: colorThemeLabel.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                onActivated: {
                    appSettings.colorTheme = colorThemeCombo.currentText
                }
            }

        }
    }

    Row {
        id: help
        height: 32
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 3
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30

        Icon {
            glyph: "\uea03"
            anchors.verticalCenter: parent.verticalCenter

        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.RichText
            text:   "<style>a:link { color: " + colors.getColor('mid') + "; }</style>" +
                    "<a href='https://github.com/eplatonoff/pilorama'>project on github</a>"

            font.family: localFont.name
            font.pixelSize: preferences.infoFontSize

            onLinkActivated: Qt.openUrlExternally(link)

        }
    }

    Row {
        id: version
        height: 32
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 3
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10

        Text {
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.RichText
            text:   "<style>a:link { color: " + colors.getColor('mid') + "; }</style>" +
                    "<a href='https://github.com/eplatonoff/pilorama/releases/latest/'>ver. " + Qt.application.version + "</a>"

            font.family: localFont.name
            font.pixelSize: preferences.infoFontSize

            onLinkActivated: Qt.openUrlExternally(link)

        }
    }

}
