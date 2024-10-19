import QtQuick

Text {
    id: icon

    property string glyph
    property bool propagateComposedEvents: true
    property int size: 24

    signal entered
    signal exited
    signal pressed
    signal released

    color: colors.getColor('light')
    font.family: iconFont.name
    font.pixelSize: size
    renderType: Text.NativeRendering
    text: glyph

    Behavior on color {
        ColorAnimation {
            duration: 80
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        propagateComposedEvents: parent.propagateComposedEvents

        onEntered: parent.entered()
        onExited: parent.exited()
        onPressed: parent.pressed()
        onReleased: parent.released()
    }
}
