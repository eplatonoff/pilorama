import QtQuick

import "Components"
import "../../Components"

Item {
    id: container
    visible: false

    Item {
        id: content

        anchors.fill: parent
        anchors.margins: 16

        Header {
            id: header
        }

        Column {
            id: settings

            spacing: 8

            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 28

            ThemeChoice {
                id: themeChoice
            }

            Setting {
                label: qsTr("Split timer to sequences")
                checked: appSettings.alwaysOnTop
                onReleased: {
                    appSettings.alwaysOnTop = !appSettings.alwaysOnTop
                }
            }

            Setting {
                label: qsTr("Keep on top")
                checked: appSettings.alwaysOnTop
                onReleased: {
                    appSettings.alwaysOnTop = !appSettings.alwaysOnTop
                }
            }

            Setting {
                label: qsTr("Close to system tray")
                checked: !appSettings.quitOnClose
                onReleased: {
                    appSettings.quitOnClose = !appSettings.quitOnClose
                }
            }

            Setting {
                label: qsTr("Keep in Dock")
                checked: appSettings.showInDock
                onReleased: {
                    appSettings.showInDock = !appSettings.showInDock
                }
            }

            Setting {
                label: qsTr("Enable sounds")
                checked: appSettings.audioNotificationsEnabled
                onReleased: {
                    appSettings.audioNotificationsEnabled = !appSettings.audioNotificationsEnabled
                }
            }
        }

        Credits {
            id: credits
        }
    }
}
