import QtQuick 2.0

Rectangle {
    id: colorSelector
    height: parent.height
    width: colWidth
    color: colors.getColor("bg")

    Behavior on width { PropertyAnimation { duration: 100 } }

    property int lineId: 0

    property real itemWidth: 25

    property real expWidth: colorModel.count * (itemWidth + colorsList.spacing)
    property real colWidth: itemWidth

    function expand(bool){
        width = bool ? expWidth : colWidth
    }

    MouseArea {
        hoverEnabled: true
        anchors.fill: parent
        onExited: {
            colorSelector.expand(false)
        }
        onFocusChanged: {
            colorSelector.expand(false)
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
                anchors.fill: parent
//                propagateComposedEvents: true
                cursorShape: Qt.PointingHandCursor

                onReleased: {
                    colorSelector.expand(true)
                    colorModel.topColor(model.color)
                    masterModel.get(lineId).color = model.color

                }
            }
        }

    }
}
