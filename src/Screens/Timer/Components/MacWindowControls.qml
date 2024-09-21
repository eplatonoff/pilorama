import QtQuick

import "../../../Components"

Item {
    id: macWindowControls

    width: 52
    height: 12

    property int buttonSize: 12

    Rectangle {
        id: closeButton

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        height: buttonSize
        width: buttonSize

        border.color: window.active ? '#E14945' : '#AAAAAAA7'
        border.width: 0.5

        radius: 50

        color: window.active ? colors.getColor('osxClose') : colors.getColor('osxInactive')

        FaIcon {
            id: closeButtonIcon

            color: '#6F000000'

            size: 10

            visible: area.containsMouse

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            glyph: "\uf00d"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                window.close()
            }
        }
    }

    Rectangle {
        id: minimizeButton

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: closeButton.right
        anchors.leftMargin: 8

        height: buttonSize
        width: buttonSize

        border.color: window.active ? '#DEA236' : '#AAAAAAA7'
        border.width: 0.5

        radius: 50

        FaIcon {
            id: minimizeButtonIcon

            color: '#6F000000'

            size: 10

            visible: area.containsMouse

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            glyph: "\uf068"
        }

        color: window.active ? colors.getColor('osxMinimize') : colors.getColor('osxInactive')

        MouseArea {
            anchors.fill: parent
            onClicked: {
                window.showMinimized()
            }
        }
    }

    Rectangle {
        id: maximizeButton

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: minimizeButton.right
        anchors.leftMargin: 8

        height: buttonSize
        width: buttonSize

        border.color: window.active ? '#26AB36' : '#AAAAAAA7'
        border.width: 0.5

        radius: 50

        FaIcon {
            id: maximizeButtonUpIcon

            color: '#6F000000'

            size: 8

            visible: area.containsMouse

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            glyph: "\uf0de"
        }

        FaIcon {
            id: maximizeButtonDownIcon

            color: '#6F000000'

            size: 8

            visible: area.containsMouse

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            glyph: "\uf0dd"
        }

        color: window.active ? colors.getColor('osxMaximize') : colors.getColor('osxInactive')

        MouseArea {
            anchors.fill: parent
            onClicked: {
                window.showMaximized()
            }
        }
    }

    MouseArea {
        id: area

        hoverEnabled: true
        propagateComposedEvents: true
        anchors.fill: parent
    }
}
