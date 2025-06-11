import QtQuick
import ".."

Item {
    id: root

    property alias checked: checkbox.checked
    property alias text: label.text
    property int cellHeight: 38
    property int fontSize: 14

    signal toggled()

    height: cellHeight
    anchors.left: parent.left
    anchors.right: parent.right

    Checkbox {
        id: checkbox
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id: label
        height: 19
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: checkbox.right
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        color: colors.getColor("dark")

        font.family: localFont.name
        font.pixelSize: root.fontSize

        renderType: Text.NativeRendering
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onReleased: root.toggled()
    }
}
