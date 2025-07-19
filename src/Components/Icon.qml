import QtQuick

Text {
    id: icon

    property string glyph
    property int size: 24
    property string source
    property bool propagateComposedEvents: true
    property bool enabled: true
    property alias containsMouse: iconMouse.containsMouse

    signal pressed()
    signal released()
    signal entered()
    signal exited()

    text: glyph
    font.family: iconFont.name
    font.pixelSize: size
    renderType: Text.NativeRendering
    color: colors.getColor('light')
    opacity: enabled ? 1.0 : 0.3
    hoverEnabled: true

    Behavior on color { ColorAnimation { duration: 80 } }

    MouseArea {
       id: iconMouse
       anchors.fill: parent
       cursorShape: Qt.PointingHandCursor
       enabled: icon.enabled
       hoverEnabled: true
       propagateComposedEvents: parent.propagateComposedEvents
       onReleased: parent.released()
       onPressed: parent.pressed()
       onEntered: parent.entered()
       onExited: parent.exited()
    }

}
