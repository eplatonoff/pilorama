import QtQuick

Item {
    id: setting

    property bool checked: false
    property string label: "... setting ..."

    signal released()

    height: 32
    anchors.right: parent.right
    anchors.left: parent.left

    Text {
        id: label
        text: parent.label
        anchors.left: parent.left
        anchors.right: checkbox.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor("dark")

        font.family: localFont.name
        font.pixelSize: 16

        renderType: Text.NativeRendering
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
