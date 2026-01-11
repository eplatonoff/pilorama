import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

ComboBox {
    id: control

    property color textColor: colors.getColor("dark")
    property color backgroundColor: colors.getColor("lighter")
    property color highlightColor: colors.getColor("light")
    property string textFontFamily: localFont.name
    property int textPixelSize: 14

    implicitHeight: 24
    implicitWidth: 120

    delegate: ItemDelegate {
        width: control.width
        height: control.implicitHeight
        highlighted: control.highlightedIndex === index
        padding: 0

        contentItem: Text {
            anchors.fill: parent
            text: modelData
            color: control.textColor
            font.family: control.textFontFamily
            font.pixelSize: control.textPixelSize
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            renderType: Text.NativeRendering
        }

        background: Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: highlighted ? control.highlightColor : "transparent"
            radius: 4
        }
    }

    indicator: Shape {
        id: indicatorShape
        x: control.width - width - 12
        y: (control.height - height) / 2
        width: 10
        height: 6

        ShapePath {
            strokeWidth: 0
            fillColor: control.textColor

            startX: 0
            startY: 0
            PathLine { x: indicatorShape.width; y: 0 }
            PathLine { x: indicatorShape.width / 2; y: indicatorShape.height }
            PathLine { x: 0; y: 0 }
        }
    }

    contentItem: Text {
        leftPadding: 14
        rightPadding: control.indicator.width + 10
        text: control.displayText
        font.family: control.textFontFamily
        font.pixelSize: control.textPixelSize
        color: control.textColor
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        renderType: Text.NativeRendering
    }

    background: Rectangle {
        implicitWidth: control.implicitWidth
        implicitHeight: control.implicitHeight
        color: control.backgroundColor
        radius: height / 2
    }

    popup: Popup {
        y: control.height + 2
        width: control.width
        implicitHeight: contentItem.contentHeight + 2
        padding: 1

        contentItem: ListView {
            clip: true
            width: parent.width
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            color: colors.getColor("bg")
            radius: 4
            border.color: control.highlightColor
            border.width: 1
        }
    }
}
