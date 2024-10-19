import QtQuick

Item {
    id: externalDrop

    anchors.fill: parent

    Rectangle {
        id: externalDropPlaceholder

        anchors.fill: parent
        border.color: colors.getColor('light')
        border.width: 2
        color: colors.getColor('bg')
        radius: 3
        visible: dropArea.containsDrag

        Text {
            id: externalDropText

            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.right: parent.right
            anchors.rightMargin: 50
            anchors.verticalCenter: parent.verticalCenter
            clip: true
            color: colors.getColor("mid")
            font.family: localFont.name
            font.pixelSize: 26
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            text: "Drop sequence preset here"
            verticalAlignment: Text.AlignVCenter
        }
    }
    DropArea {
        id: dropArea

        anchors.fill: parent

        onDropped: function (drop) {
            if (drop.hasText) {
                if (drop.proposedAction == Qt.MoveAction || drop.proposedAction == Qt.CopyAction) {
                    timerModel.data = fileDialogue.openFile(drop.text).data;
                    timerModel.title = fileDialogue.openFile(drop.text).title;
                    timerModel.load();
                    drop.acceptProposedAction();
                }
            }
        }
    }
}
