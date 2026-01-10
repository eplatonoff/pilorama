import QtQuick

Text {
    id: icon

    property string glyph
    property int size: 24
    property string source
    property bool propagateComposedEvents: true
    property int cursorShape: Qt.PointingHandCursor

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
       hoverEnabled: true
       cursorShape: parent.cursorShape
       propagateComposedEvents: parent.propagateComposedEvents
       onReleased: parent.released()
       onPressed: parent.pressed()
       onEntered: parent.entered()
       onExited: parent.exited()
    }

}
