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
    }

    ListModel{
        id: colorModel
        property bool darkMode: appSettings.darkMode

        Component.onCompleted: {
            updateModel();
            topColor(masterModel.get(lineId).color);
        }
        onDarkModeChanged: updateModel()

        function updateModel(){
            reloadColors()
            topColor(masterModel.get(lineId).color)
        }

        function reloadColors(){
            clear()
            colors.list().forEach(color => { append({"color" : color}) })
        }

        function topColor(color){
            var id
             reloadColors()
            for(var i = 0; i < count; i++){
                if(color === get(i).color) {id = i; break}
                else{ id = undefined }
            }

            if(i === undefined || !color){throw "No matching color"}
            move(id, 0, 1)
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
