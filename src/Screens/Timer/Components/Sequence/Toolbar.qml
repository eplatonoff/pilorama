import QtQuick

import "../../../../Components"

Item {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    height: 24

    FileDialogue {
        id: fileDialogue
    }

    Behavior on height {
        NumberAnimation {
            duration: 150
        }
    }

    Rectangle {
        id: layoutDivider
        height: 1
        width: parent.width
        color: colors.getColor("lighter")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    Item {
        width: parent.width
        height: 14
        anchors.bottom: parent.bottom

        FaIcon {
            id: loadButton
            glyph: "\uf07c"
            size: 14
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            onReleased: { fileDialogue.openDialogue() }

        }

        FaIcon {
            id: saveButton
            glyph: "\uf0c7"
            size: 14
            anchors.left: loadButton.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter

            onReleased: { fileDialogue.saveDialogue() }
        }

        Item {
            id: addButton

            anchors.left: saveButton.right
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 14

            MouseArea {
                id: addButtonTrigger
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    timerModel.add()
                    focus = true
                }
            }

            Item {
                anchors.fill: parent

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    FaIcon {
                        id: addIcon
                        glyph: "\u002b"
                        size: 12
                        color: colors.getColor("mid")
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: qsTr('Add split')
                        anchors.verticalCenter: parent.verticalCenter

                        font.family: localFont.name
                        font.pixelSize: 12

                        renderType: Text.NativeRendering

                        color: colors.getColor("dark")
                    }
                }
            }
        }
    }
}
