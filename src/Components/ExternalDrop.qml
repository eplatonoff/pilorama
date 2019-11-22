import QtQuick 2.0

Item{
    id: externalDrop
    anchors.fill: parent

    Rectangle{
        id: rectangle
        visible: dropData.containsDrag ? true : false
        color: colors.getColor('bg')
        radius: 3
        border.color: colors.getColor('light')
        border.width: 2
        anchors.fill: parent

        Text {
            height: 150
            color: colors.getColor("mid")
            text: "Drop "+ window.title + " preset here"
            clip: true
            fontSizeMode: Text.Fit
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.left: parent.left
            anchors.leftMargin: 50
            font.pointSize: 26
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    DropArea {
        id: dropData
        anchors.fill: parent
        keys: ["text/plain"]
//        onEntered: if (!acceptDropCB.checked) {
//            drag.accepted = false
//            rejectAnimation.start()
//        }
        onDropped: if (drop.hasText && acceptDropCB.checked) {
            if (drop.proposedAction == Qt.MoveAction || drop.proposedAction == Qt.CopyAction) {
                item.display = drop.text
                drop.acceptProposedAction()
            }
        }

    }

}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:2;anchors_width:447}
}
##^##*/
