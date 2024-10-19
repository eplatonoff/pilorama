import QtQuick

Text {
    id: icon

    property string glyph
    property int size: 18

    signal entered
    signal exited
    signal pressed
    signal released

    color: area.containsMouse ? colors.getColor('mid') : colors.getColor('light')
    font.family: awesomeFont.name
    font.pixelSize: size
    height: size
    horizontalAlignment: Text.AlignHCenter
    renderType: Text.NativeRendering
    text: glyph
    width: size

    Behavior on color {
        ColorAnimation {
            duration: 50
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onEntered: parent.entered()
        onExited: parent.exited()
        onPressed: parent.pressed()
        onReleased: parent.released()
    }
}
