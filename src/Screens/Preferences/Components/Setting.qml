import QtQuick

Item {
    id: setting

    property bool checked: false
    property string label: "... setting ..."

    signal released()

    height: 24
    anchors.right: parent.right
    anchors.left: parent.left

    Checkbox {
        id: checkbox
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        checked: setting.checked
    }

    Text {
        id: label
        text: parent.label
        anchors.left: checkbox.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor("dark")

        font.family: localFont.name
        font.pixelSize: 16

        renderType: Text.NativeRendering
    }


    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onReleased: parent.released()
    }
}
