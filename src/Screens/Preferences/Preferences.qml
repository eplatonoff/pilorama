import QtQuick

import "Components"

Item {
    id: container

    visible: false

    Item {
        id: content

        anchors.fill: parent
        anchors.margins: 16

        Title {
            id: header

        }
        Column {
            id: settings

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.topMargin: 28
            spacing: 8

            ThemeChoice {
                id: themeChoice

            }
            Setting {
                checked: appSettings.alwaysOnTop
                label: qsTr("Keep on top")

                onReleased: {
                    appSettings.alwaysOnTop = !appSettings.alwaysOnTop;
                }
            }
            Setting {
                checked: !appSettings.quitOnClose
                label: qsTr("Close to system tray")

                onReleased: {
                    appSettings.quitOnClose = !appSettings.quitOnClose;
                }
            }
            Setting {
                checked: appSettings.showInDock
                label: qsTr("Keep in Dock")

                onReleased: {
                    appSettings.showInDock = !appSettings.showInDock;
                }
            }
            Setting {
                checked: appSettings.audioNotificationsEnabled
                label: qsTr("Enable sounds")

                onReleased: {
                    appSettings.audioNotificationsEnabled = !appSettings.audioNotificationsEnabled;
                }
            }
        }
        Credits {
            id: credits

        }
    }
}
