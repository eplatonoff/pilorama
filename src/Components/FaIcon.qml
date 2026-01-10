import QtQuick
import QtQuick.Controls

Text {
    id: icon

    property string glyph
    property int size: 18
    property string tooltip

    signal entered
    signal exited
    signal pressed
    signal released

    ToolTip.delay: 500
    ToolTip.text: tooltip
    ToolTip.visible: (tooltip !== "" && area.containsMouse)
    color: area.containsMouse ? colors.getColor("mid") : colors.getColor("light")
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
