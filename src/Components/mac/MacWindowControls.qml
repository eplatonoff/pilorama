import QtQuick
import QtQuick.Window
import QtQuick.Shapes

Item {
    id: macWindowControls

    required property Window windowRef
    required property var colors

    property int buttonSize: 12
    property real buttonBorderWidth: 0.5
    property int glyphBox: 7
    property real glyphStroke: 1.2
    property real glyphCenterXOffset: 0.5
    property real glyphCenterYOffset: 0.5
    property real minimizeGlyphCenterXOffset: glyphCenterXOffset + 0.5
    property real minimizeGlyphCenterYOffset: glyphCenterYOffset + 0.25

    property real closeInset: 1.2
    property int minimizeGlyphWidth: 9
    property int minimizeGlyphHeight: 7
    property real minimizeInset: 0.75
    property real minimizeHeight: 1.0
    property real maximizeInset: 0.8
    property real maximizeGap: 0.8

    property color closeBorderColor: "#D14F41"
    property color minimizeBorderColor: "#D7A03E"
    property color maximizeBorderColor: "#50A73D"
    property color inactiveBorderColor: "#AAAAAAA7"

    property color closeGlyphColor: "#69110A"
    property color minimizeGlyphColor: "#8F591D"
    property color maximizeGlyphColor: "#286017"

    height: 12
    width: 52

    Rectangle {
        id: closeButton

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: true
        border.color: macWindowControls.windowRef.active
                      ? macWindowControls.closeBorderColor
                      : macWindowControls.inactiveBorderColor
        border.width: macWindowControls.buttonBorderWidth
        color: macWindowControls.windowRef.active
               ? macWindowControls.colors.getColor("osxClose")
               : macWindowControls.colors.getColor("osxInactive")
        height: buttonSize
        radius: 50
        width: buttonSize

        Shape {
            id: closeButtonIcon

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: macWindowControls.glyphCenterXOffset
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: macWindowControls.glyphCenterYOffset
            width: macWindowControls.glyphBox
            height: macWindowControls.glyphBox
            visible: area.containsMouse

            ShapePath {
                strokeWidth: macWindowControls.glyphStroke
                strokeColor: macWindowControls.closeGlyphColor
                capStyle: ShapePath.SquareCap
                joinStyle: ShapePath.RoundJoin
                fillColor: "transparent"
                startX: macWindowControls.closeInset
                startY: macWindowControls.closeInset
                PathLine {
                    x: macWindowControls.glyphBox - macWindowControls.closeInset
                    y: macWindowControls.glyphBox - macWindowControls.closeInset
                }
            }
            ShapePath {
                strokeWidth: macWindowControls.glyphStroke
                strokeColor: macWindowControls.closeGlyphColor
                capStyle: ShapePath.SquareCap
                joinStyle: ShapePath.RoundJoin
                fillColor: "transparent"
                startX: macWindowControls.glyphBox - macWindowControls.closeInset
                startY: macWindowControls.closeInset
                PathLine {
                    x: macWindowControls.closeInset
                    y: macWindowControls.glyphBox - macWindowControls.closeInset
                }
            }
        }
        MouseArea {
            anchors.fill: parent

            onClicked: {
                macWindowControls.windowRef.close();
            }
        }
    }
    Rectangle {
        id: minimizeButton

        anchors.left: closeButton.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: true
        border.color: macWindowControls.windowRef.active
                      ? macWindowControls.minimizeBorderColor
                      : macWindowControls.inactiveBorderColor
        border.width: macWindowControls.buttonBorderWidth
        color: macWindowControls.windowRef.active
               ? macWindowControls.colors.getColor("osxMinimize")
               : macWindowControls.colors.getColor("osxInactive")
        height: buttonSize
        radius: 50
        width: buttonSize

        Shape {
            id: minimizeButtonIcon

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: macWindowControls.minimizeGlyphCenterXOffset
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: macWindowControls.minimizeGlyphCenterYOffset
            width: macWindowControls.minimizeGlyphWidth
            height: macWindowControls.minimizeGlyphHeight
            visible: area.containsMouse

            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: macWindowControls.minimizeGlyphColor
                startX: macWindowControls.minimizeInset
                startY: macWindowControls.minimizeGlyphHeight / 2 - macWindowControls.minimizeHeight / 2
                PathLine {
                    x: macWindowControls.minimizeGlyphWidth - macWindowControls.minimizeInset
                    y: macWindowControls.minimizeGlyphHeight / 2 - macWindowControls.minimizeHeight / 2
                }
                PathLine {
                    x: macWindowControls.minimizeGlyphWidth - macWindowControls.minimizeInset
                    y: macWindowControls.minimizeGlyphHeight / 2 + macWindowControls.minimizeHeight / 2
                }
                PathLine {
                    x: macWindowControls.minimizeInset
                    y: macWindowControls.minimizeGlyphHeight / 2 + macWindowControls.minimizeHeight / 2
                }
                PathLine {
                    x: macWindowControls.minimizeInset
                    y: macWindowControls.minimizeGlyphHeight / 2 - macWindowControls.minimizeHeight / 2
                }
            }
        }
        MouseArea {
            anchors.fill: parent

            onClicked: {
                macWindowControls.windowRef.showMinimized();
            }
        }
    }
    Rectangle {
        id: maximizeButton

        anchors.left: minimizeButton.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: true
        border.color: macWindowControls.windowRef.active
                      ? macWindowControls.maximizeBorderColor
                      : macWindowControls.inactiveBorderColor
        border.width: macWindowControls.buttonBorderWidth
        color: macWindowControls.windowRef.active
               ? macWindowControls.colors.getColor("osxMaximize")
               : macWindowControls.colors.getColor("osxInactive")
        height: buttonSize
        radius: 50
        width: buttonSize

        Shape {
            id: maximizeButtonIcon

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: macWindowControls.glyphCenterXOffset
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: macWindowControls.glyphCenterYOffset
            width: macWindowControls.glyphBox
            height: macWindowControls.glyphBox
            visible: area.containsMouse

            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: macWindowControls.maximizeGlyphColor
                startX: macWindowControls.maximizeInset
                startY: macWindowControls.maximizeInset
                PathLine {
                    x: macWindowControls.glyphBox - macWindowControls.maximizeInset - macWindowControls.maximizeGap
                    y: macWindowControls.maximizeInset
                }
                PathLine {
                    x: macWindowControls.maximizeInset
                    y: macWindowControls.glyphBox - macWindowControls.maximizeInset - macWindowControls.maximizeGap
                }
                PathLine {
                    x: macWindowControls.maximizeInset
                    y: macWindowControls.maximizeInset
                }
            }
            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: macWindowControls.maximizeGlyphColor
                startX: macWindowControls.glyphBox - macWindowControls.maximizeInset
                startY: macWindowControls.glyphBox - macWindowControls.maximizeInset
                PathLine {
                    x: macWindowControls.glyphBox - macWindowControls.maximizeInset
                    y: macWindowControls.maximizeInset + macWindowControls.maximizeGap
                }
                PathLine {
                    x: macWindowControls.maximizeInset + macWindowControls.maximizeGap
                    y: macWindowControls.glyphBox - macWindowControls.maximizeInset
                }
                PathLine {
                    x: macWindowControls.glyphBox - macWindowControls.maximizeInset
                    y: macWindowControls.glyphBox - macWindowControls.maximizeInset
                }
            }
        }
        MouseArea {
            anchors.fill: parent

            onClicked: {
                if (macWindowControls.windowRef.windowState & Qt.WindowMaximized) {
                    macWindowControls.windowRef.showNormal();
                } else {
                    macWindowControls.windowRef.showMaximized();
                }
            }
        }
    }
    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
    }
}
