import QtQuick

Item {
    id: externalDrop

    property bool validFile: false

    anchors.fill: parent

    Rectangle {
        id: rectangle

        anchors.fill: parent
        border.color: colors.getColor('light')
        border.width: 2
        color: colors.getColor('bg')
        radius: 3
        visible: validFile

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
            height: 150
            horizontalAlignment: Text.AlignHCenter
            text: "Not valid file type"
            verticalAlignment: Text.AlignVCenter
        }
    }
    DropArea {
        id: dropData

        anchors.fill: parent

        onDropped: if (drop.hasText) {
            if (drop.proposedAction == Qt.MoveAction || drop.proposedAction == Qt.CopyAction) {
                timerModel.data = fileDialogue.openFile(drop.text).data;
                timerModel.title = fileDialogue.openFile(drop.text).title;
                timerModel.load();
                drop.acceptProposedAction();
                externalDrop.validFile = false;
            }
        }
        onEntered: {
            externalDrop.validFile = true;
            drag.accept();
            externalDropText.text = "Drop sequence preset here";
        }
        onExited: {
            externalDrop.validFile = false;
        }
    }
}
