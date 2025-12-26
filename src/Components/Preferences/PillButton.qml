import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string text: ""
    property color textColor: colors.getColor("dark")
    property color backgroundColor: colors.getColor("lighter")
    property int textPixelSize: 14
    property string textFontFamily: localFont.name
    property int horizontalPadding: 14
    property int maxWidth: 120

    property string tooltipText: ""
    property int tooltipPixelSize: 12
    property string tooltipFontFamily: localFont.name
    property int tooltipElide: Text.ElideRight
    property int tooltipDelay: 300
    property int tooltipTimeout: 2500
    property int tooltipPadding: 6
    property int tooltipMaxWidth: Math.max(240, window ? window.width - 40 : 400)

    signal pressed()

    implicitHeight: 24
    implicitWidth: Math.min(label.implicitWidth + horizontalPadding * 2, maxWidth)
    height: implicitHeight
    width: implicitWidth

    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor
        radius: height / 2

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onPressed: root.pressed()
        }

        Text {
            id: label
            text: root.text
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            elide: Text.ElideRight
            font.family: root.textFontFamily
            font.pixelSize: root.textPixelSize
            color: root.textColor
            clip: true
        }
    }

    ToolTip {
        id: tip
        parent: root
        width: Math.min(implicitWidth, root.tooltipMaxWidth)
        x: (parent.width - width) / 2
        y: parent.height + 6
        visible: hoverArea.containsMouse && root.tooltipText !== ""
        delay: root.tooltipDelay
        timeout: root.tooltipTimeout

        contentItem: Label {
            text: root.tooltipText
            color: colors.getColor("dark")
            font.family: root.tooltipFontFamily
            font.pixelSize: root.tooltipPixelSize
            padding: root.tooltipPadding
            elide: root.tooltipElide
            wrapMode: Text.NoWrap
            clip: true
            width: tip.width
        }

        background: Rectangle {
            color: colors.getColor("bg")
            radius: 4
            border.color: colors.getColor("light")
            border.width: 1
        }
    }
}
