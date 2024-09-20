import QtQuick

Text {
    id: icon

    property string glyph
    property int size: 18

    horizontalAlignment: Text.AlignHCenter
    width: size
    height: size

    text: glyph
    font.family: awesomeFont.name
    font.pixelSize: size
    renderType: Text.NativeRendering
    color: area.containsMouse ? colors.getColor('mid') : colors.getColor('light')

    signal pressed()

    signal released()

    signal entered()

    signal exited()

    MouseArea {
        id: area

        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onReleased: parent.released()
        onPressed: parent.pressed()
        onEntered: parent.entered()
        onExited: parent.exited()
    }

    Behavior on color {
        ColorAnimation {
            duration: 50
        }
    }
}
