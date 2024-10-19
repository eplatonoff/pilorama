import QtQuick

Item {
    id: macWindowControls

    property int buttonSize: 12

    height: 12
    width: 52

    Rectangle {
        id: closeButton

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        border.color: window.active ? '#E14945' : '#AAAAAAA7'
        border.width: 0.5
        color: window.active ? colors.getColor('osxClose') : colors.getColor('osxInactive')
        height: buttonSize
        radius: 50
        width: buttonSize

        FaIcon {
            id: closeButtonIcon

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: '#6F000000'
            glyph: "\uf00d"
            size: 10
            visible: area.containsMouse
        }
        MouseArea {
            anchors.fill: parent

            onClicked: {
                window.close();
            }
        }
    }
    Rectangle {
        id: minimizeButton

        anchors.left: closeButton.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        border.color: window.active ? '#DEA236' : '#AAAAAAA7'
        border.width: 0.5
        color: window.active ? colors.getColor('osxMinimize') : colors.getColor('osxInactive')
        height: buttonSize
        radius: 50
        width: buttonSize

        FaIcon {
            id: minimizeButtonIcon

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: '#6F000000'
            glyph: "\uf068"
            size: 10
            visible: area.containsMouse
        }
        MouseArea {
            anchors.fill: parent

            onClicked: {
                window.showMinimized();
            }
        }
    }
    Rectangle {
        id: maximizeButton

        anchors.left: minimizeButton.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        border.color: window.active ? '#26AB36' : '#AAAAAAA7'
        border.width: 0.5
        color: window.active ? colors.getColor('osxMaximize') : colors.getColor('osxInactive')
        height: buttonSize
        radius: 50
        width: buttonSize

        FaIcon {
            id: maximizeButtonUpIcon

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: '#6F000000'
            glyph: "\uf0de"
            size: 8
            visible: area.containsMouse
        }
        FaIcon {
            id: maximizeButtonDownIcon

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: '#6F000000'
            glyph: "\uf0dd"
            size: 8
            visible: area.containsMouse
        }
        MouseArea {
            anchors.fill: parent

            onClicked: {
                window.showMaximized();
            }
        }
    }
    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
    }
}
