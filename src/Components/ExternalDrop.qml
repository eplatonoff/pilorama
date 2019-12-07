import QtQuick 2.0

Item{
    id: externalDrop
    anchors.fill: parent

    property bool validFile: false

    Rectangle{
        id: rectangle
        visible: validFile
        color: colors.getColor('bg')
        radius: 3
        border.color: colors.getColor('light')
        border.width: 2
        anchors.fill: parent

        Text {
            id: externalDropText
            height: 150
            color: colors.getColor("mid")
            text: "Not valid file type"
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
        onEntered: {
                externalDrop.validFile = true
                drag.accept()
                externalDropText.text = "Drop "+ window.title + " preset here"
        }
        onExited: {
                externalDrop.validFile = false
        }
        onDropped: if (drop.hasText) {
            if (drop.proposedAction == Qt.MoveAction || drop.proposedAction == Qt.CopyAction) {

                masterModel.data = fileDialogue.openFile(drop.text).data
                masterModel.title = fileDialogue.openFile(drop.text).title
                masterModel.load()

                drop.acceptProposedAction()
                externalDrop.validFile = false
            }
        }

    }

}
