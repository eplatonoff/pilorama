import QtQuick

Rectangle {
    id: colorSelector
    height: parent.height
    width: colWidth
    color: parent.color

    property int lineId: 0

    property real itemWidth: 25
    property bool expanded: false
    property real expWidth: colorModel.count * (itemWidth + colorsList.spacing)
    property real colWidth: itemWidth

    property bool currentItem: delegateItem.ListView.isCurrentItem
    property bool blockEdits: sequence.blockEdits
    property bool rowHovered: false

    property bool dimm: false

    Behavior on width {NumberAnimation{duration: 150; easing.type: Easing.OutQuad}}

    onCurrentItemChanged: { activateBlink(currentItem) }

    Connections {
        target: globalTimer
        function onRunningChanged(running) { activateBlink(running && colorSelector.currentItem) }
    }

    onExpandedChanged: {
        width = expanded ? expWidth : colWidth
        if (expanded) {
            if (sequenceView.openColorSelector
                && sequenceView.openColorSelector !== colorSelector) {
                sequenceView.openColorSelector.expanded = false
            }
            sequenceView.openColorSelector = colorSelector
        } else if (sequenceView.openColorSelector === colorSelector) {
            sequenceView.openColorSelector = null
        }
    }

    function activateBlink(bool){
        if(bool && masterModel.get(lineId).duration !== 0){
            blinkTimer.start()
        } else {
            blinkTimer.stop()
            colorsList.opacity = 1
        }

    }

    function dimmer(color) {
        const dimColor = colors.getColor('light')
        if (!splitToSequence && globalTimer.remainingTime){
            dimm = true
            return dimColor
        } else if (model.duration === 0){
            dimm = true
            return dimColor
        } else {
            dimm = false
            return color
        }
    }

    ListModel{
        id: colorModel
        property bool darkMode: appSettings.darkMode

        Component.onCompleted: {
           loadModel()
           topColor(masterModel.get(lineId).color);
        }
        onDarkModeChanged: loadModel()

        function loadModel(){
            clear()
            colors.list().forEach((color, index) => { append({"id": index, "color" : color}) })
            topColor(masterModel.get(lineId).color)
        }

        function reorder(){
            for(var i = 0; i<count; i++){
                move(i, get(i).id, 1)
            }

        }



        function topColor(color){
            var top
            reorder()
            for(var i = 0; i < count; i++){
                if(color === get(i).color) {top = i; break}
                else{ top = undefined }
            }

            if(top === undefined || !color){throw "No matching color"}
            move(top, 0, 1)
        }
    }

    ListView{
        id: colorsList
        interactive: false
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: 2

        Behavior on opacity { NumberAnimation{properties: "opacity"; duration: 200; easing.type: Easing.OutQuad}}

        model: colorModel

        delegate: Item {

            id: colorItem
            height: colorSelector.height
            width: colorSelector.itemWidth
            Rectangle {
                id: hoverRing
                width: 17
                height: 17
                radius: 9
                color: "transparent"
                border.width: 2
                border.color: colors.getColor("light")
                anchors.centerIn: parent
                opacity: (colorItemHover.hovered || colorSelector.rowHovered) ? 1 : 0
                visible: index === 0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            Rectangle {
                width: 13
                height: 13
                color: colorSelector.dimmer(colors.getColor(model.color))
                radius: 30
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            MouseArea{

                visible: !(colorSelector.blockEdits || dimm)
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    if(index === 0){
                       expanded = !expanded
                    } else {
                        colorModel.topColor(model.color)
                        masterModel.get(lineId).color = model.color
                        expanded = false
                    }
                }
            }

            HoverHandler {
                id: colorItemHover
                enabled: !(colorSelector.blockEdits || dimm)
            }
        }

    }

    Timer{

        id: blinkTimer

        interval: 500
        running: false
        repeat: true
        triggeredOnStart: false

        onTriggered: { colorsList.opacity = !colorsList.opacity }
    }
}
