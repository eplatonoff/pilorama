import QtQuick

Rectangle {
    id: colorSelector

    property real collapsedWidth: itemWidth
    property bool currentItem: delegateItem.ListView.isCurrentItem
    property bool expanded: false
    property real expandedWidth: colorModel.count * (itemWidth + colorsList.spacing)
    property int itemIndex
    property real itemWidth: 25

    color: colors.getColor("bg")
    height: 25
    radius: 30
    width: collapsedWidth

    Behavior on color {
        ColorAnimation {
            duration: sequence.switchModeDuration
        }
    }
    Behavior on width {
        NumberAnimation {
            duration: sequence.switchModeDuration
        }
    }

    onExpandedChanged: {
        width = expanded ? expandedWidth : collapsedWidth;
        color = expanded ? colors.getColor("mid") : colors.getColor("bg");
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        visible: sequence.editable

        onExited: {
            expanded = false;
        }
        onFocusChanged: {
            expanded = false;
        }
    }
    ListModel {
        id: colorModel

        property bool darkMode: appSettings.darkMode

        function loadModel() {
            clear();
            colors.palette().forEach((color, index) => {
                append({
                    "id": index,
                    "color": color
                });
            });
            topColor(timerModel.get(itemIndex).color);
        }
        function reorder() {
            for (var i = 0; i < count; i++) {
                move(i, get(i).id, 1);
            }
        }
        function topColor(color) {
            var top;
            reorder();
            for (var i = 0; i < count; i++) {
                if (color === get(i).color) {
                    top = i;
                    break;
                } else {
                    top = undefined;
                }
            }
            if (top === undefined || !color) {
                throw "No matching color";
            }
            move(top, 0, 1);
        }

        Component.onCompleted: {
            loadModel();
            topColor(timerModel.get(itemIndex).color);
        }
        onDarkModeChanged: loadModel()
    }
    ListView {
        id: colorsList

        anchors.fill: parent
        clip: true
        interactive: false
        model: colorModel
        orientation: ListView.Horizontal
        spacing: sequence.editable ? 2 : 0

        delegate: Item {
            id: colorItem

            height: colorSelector.height
            width: colorSelector.itemWidth

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                // color: colorSelector.dimmer(colors.getColor(model.color))
                color: colors.getColor(model.color)
                height: 13
                radius: 30
                width: 13
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                visible: sequence.editable

                onReleased: {
                    if (index === 0) {
                        expanded = !expanded;
                    } else {
                        colorModel.topColor(model.color);
                        timerModel.get(itemIndex).color = model.color;
                    }
                }
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
                properties: "opacity"
            }
        }
    }
}
