import QtQuick 2.0

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
    property bool blockAction: sequence.blockEdits

    onCurrentItemChanged: { activateBlink(currentItem) }

    onExpandedChanged: { width = expanded ? expWidth : colWidth }

    function activateBlink(bool){
        if(bool){
            blinkTimer.start()
        } else {
            blinkTimer.stop()
            colorsList.opacity = 1
        }

    }

    MouseArea {

        visible: !colorSelector.blockAction
        hoverEnabled: true
        anchors.fill: parent
        onExited: {
            expanded = false
        }
        onFocusChanged: {
            expanded = false
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
        spacing: 5

        Behavior on opacity { NumberAnimation{properties: "opacity"; duration: 100}}

        model: colorModel

        delegate: Item {

            id: colorItem
            height: parent.height
            width: colorSelector.itemWidth

            Rectangle {
                width: 13
                height: 13
                color: colors.getColor(model.color)
                radius: 30
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            MouseArea{

                visible: !colorSelector.blockAction
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    if(index === 0){
                       expanded = !expanded
                    } else {
                        colorModel.topColor(model.color)
                        masterModel.get(lineId).color = model.color
                    }
                }
            }
        }

    }

    Timer{

        id: blinkTimer

        interval: 500
        running: false
        repeat: true

        onTriggered: { colorsList.opacity = !colorsList.opacity }
    }
}
