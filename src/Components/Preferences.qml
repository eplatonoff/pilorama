import QtQuick
import QtQuick.Controls

import "Preferences"

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
        PreferenceItem {
            id: splitToSequence
            cellHeight: preferences.cellHeight
            fontSize: preferences.fontSize
            checked: preferences.splitToSequence
            text: qsTr("Split timer to sequence")
            onToggled: preferences.splitToSequence = !preferences.splitToSequence
        }

        PreferenceItem {
            id: onTop
            cellHeight: preferences.cellHeight
            fontSize: preferences.fontSize
            checked: window.alwaysOnTop
            text: qsTr("Always on top")
            onToggled: window.alwaysOnTop = !window.alwaysOnTop
        }

        PreferenceItem {
            id: closeOnQuit
            cellHeight: preferences.cellHeight
            fontSize: preferences.fontSize
            checked: !window.quitOnClose
            text: qsTr("On close hide to system tray")
            onToggled: window.quitOnClose = !window.quitOnClose
        }

        PreferenceItem {
            id: showInDock
            visible: Qt.platform.os === "osx"
            cellHeight: preferences.cellHeight
            fontSize: preferences.fontSize
            checked: appSettings.showInDock
            text: qsTr("Show app in Dock")
            onToggled: appSettings.showInDock = !appSettings.showInDock
        }

        PreferenceItem {
            id: pauseUISetting
            cellHeight: preferences.cellHeight
            fontSize: preferences.fontSize
            checked: appSettings.showPauseUI
            text: qsTr("Enable pause button")
            onToggled: appSettings.showPauseUI = !appSettings.showPauseUI
        }

        PreferenceItem {
            id: segmentPopUp
            cellHeight: preferences.cellHeight
            fontSize: preferences.fontSize
            checked: appSettings.showOnSegmentStart
            text: qsTr("Show window on segment start")
            onToggled: appSettings.showOnSegmentStart = !appSettings.showOnSegmentStart
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
                palette.buttonText: colors.getColor("dark")
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
