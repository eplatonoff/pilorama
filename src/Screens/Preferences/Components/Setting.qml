import QtQuick

Item {
    id: setting

    property bool checked: false
    property string label: "... setting ..."

    signal released

    anchors.left: parent.left
    anchors.right: parent.right
    height: 32

    Text {
        id: label

        anchors.left: parent.left
        anchors.right: checkbox.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor("dark")
        font.family: localFont.name
        font.pixelSize: 16
        renderType: Text.NativeRendering
        text: parent.label
    }
    Checkbox {
        id: checkbox

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: setting.checked
    }
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onReleased: parent.released()
    }
}
