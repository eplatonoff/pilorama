import QtQuick 2.15
import QtQuick.Controls 2.15

ScrollBar {
    id: customScrollBar

    property bool viewContainsMouse: false
    property int transitionDuration: 160
    property color handleColor: colors.getColor("lighter")
    property real handleOpacity: 0.7

    implicitWidth: 10
    implicitHeight: 100

    interactive: true
    hoverEnabled: true
    active: viewContainsMouse || hovered || pressed

    contentItem: Rectangle {
        id: handle
        implicitWidth: 10
        implicitHeight: 100
        color: customScrollBar.handleColor
        radius: 5
        opacity: (customScrollBar.active ? 1.0 : 0.0) * customScrollBar.handleOpacity
        Behavior on opacity { NumberAnimation { duration: customScrollBar.transitionDuration } }

        HoverHandler {
            cursorShape: customScrollBar.pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        }

    }

    background: Rectangle {
        implicitWidth: 10
        implicitHeight: 100
        color: "transparent"
        visible: false
    }
}
