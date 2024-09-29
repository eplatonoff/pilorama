import QtQuick

import "../../../../Components"

Item {
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    clip: true
    height: sequence.editable ? 28 : 0

    Behavior on height {
        NumberAnimation {
            duration: sequence.switchModeDuration
        }
    }

    FileDialogue {
        id: fileDialogue

    }
    Rectangle {
        id: layoutDivider

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        color: colors.getColor("lighter")
        height: 1
        width: parent.width
    }
    Item {
        anchors.bottom: parent.bottom
        height: 14
        width: parent.width

        FaIcon {
            id: loadButton

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            glyph: "\uf07c"
            size: 14

            onReleased: {
                fileDialogue.openDialogue();
            }
        }
        FaIcon {
            id: saveButton

            anchors.left: loadButton.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            glyph: "\uf0c7"
            size: 14

            onReleased: {
                fileDialogue.saveDialogue();
            }
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
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onReleased: {
                    timerModel.add();
                    focus = true;
                }
            }
            Item {
                anchors.fill: parent

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    FaIcon {
                        id: addIcon

                        anchors.verticalCenter: parent.verticalCenter
                        color: colors.getColor("mid")
                        glyph: "\u002b"
                        size: 12
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: colors.getColor("dark")
                        font.family: localFont.name
                        font.pixelSize: 12
                        renderType: Text.NativeRendering
                        text: qsTr('Add split')
                    }
                }
            }
        }
    }
}
