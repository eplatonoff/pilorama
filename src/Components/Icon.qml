import QtQuick

Text {
    id: icon

    property string glyph
    property int size: 24
    property string source

    signal pressed()
    signal released()
    signal entered()
    signal exited()

    text: glyph
    font.family: iconFont.name
    font.pixelSize: size
    renderType: Text.NativeRendering
    color: colors.getColor('light')

    Behavior on color { ColorAnimation { duration: 80 } }

    MouseArea {
       anchors.fill: parent
       cursorShape: Qt.PointingHandCursor
       propagateComposedEvents: true
       onReleased: parent.released()
       onPressed: parent.pressed()
       onEntered: parent.entered()
       onExited: parent.exited()
    }

}
