import QtQuick

Rectangle {
    id: colorSelector
    height: 25
    width: collapsedWidth

    color: colors.getColor("bg")
    radius: 30

    property int itemIndex

    property real itemWidth: 25
    property bool expanded: false

    property real expandedWidth: colorModel.count * (itemWidth + colorsList.spacing)
    property real collapsedWidth: itemWidth

    property bool currentItem: delegateItem.ListView.isCurrentItem

    Behavior on width {
        NumberAnimation {
            duration: 150; easing.type: Easing.OutQuad
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150; easing.type: Easing.OutQuad
        }
    }

    onExpandedChanged: {
        width = expanded ? expandedWidth : collapsedWidth
        color = expanded ? colors.getColor("mid") : colors.getColor("bg")
    }

    MouseArea {
        hoverEnabled: true
        anchors.fill: parent
        onExited: {
            expanded = false
        }
        onFocusChanged: {
            expanded = false
        }
    }

    ListModel {
        id: colorModel
        property bool darkMode: appSettings.darkMode

        Component.onCompleted: {
            loadModel()
            topColor(timerModel.get(itemIndex).color);
        }
        onDarkModeChanged: loadModel()

        function loadModel() {
            clear()
            colors.palette().forEach((color, index) => {
                append({"id": index, "color": color})
            })
            topColor(timerModel.get(itemIndex).color)
        }

        function reorder() {
            for (var i = 0; i < count; i++) {
                move(i, get(i).id, 1)
            }

        }

        function topColor(color) {
            var top
            reorder()
            for (var i = 0; i < count; i++) {
                if (color === get(i).color) {
                    top = i;
                    break
                } else {
                    top = undefined
                }
            }

            if (top === undefined || !color) {
                throw "No matching color"
            }
            move(top, 0, 1)
        }
    }

    ListView {
        id: colorsList
        interactive: false
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: 2

        Behavior on opacity {
            NumberAnimation {
                properties: "opacity"; duration: 200; easing.type: Easing.OutQuad
            }
        }

        model: colorModel

        delegate: Item {

            id: colorItem
            height: colorSelector.height
            width: colorSelector.itemWidth

            Rectangle {
                width: 13
                height: 13
                // color: colorSelector.dimmer(colors.getColor(model.color))
                color: colors.getColor(model.color)
                radius: 30
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    if (index === 0) {
                        expanded = !expanded
                    } else {
                        colorModel.topColor(model.color)
                        timerModel.get(itemIndex).color = model.color
                    }
                }
            }
        }

    }
}
