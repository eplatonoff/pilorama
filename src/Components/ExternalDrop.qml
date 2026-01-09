import QtQuick

Item{
    id: externalDrop
    anchors.fill: parent

    property bool validFile: false

    function isSequenceDrag(drag) {
        return drag.keys && drag.keys.indexOf("sequenceItems") !== -1
    }

    function isJsonUrl(url) {
        if (!url) {
            return false
        }
        const value = url.toString().toLowerCase()
        return value.endsWith(".json") || value.indexOf(".json?") !== -1 || value.indexOf(".json#") !== -1
    }

    function hasJsonFile(drag) {
        if (drag.hasUrls) {
            for (var i = 0; i < drag.urls.length; i++) {
                if (isJsonUrl(drag.urls[i])) {
                    return true
                }
            }
        }
        if (drag.hasText) {
            return isJsonUrl(drag.text)
        }
        return false
    }

    function firstJsonUrl(drag) {
        if (drag.hasUrls) {
            for (var i = 0; i < drag.urls.length; i++) {
                if (isJsonUrl(drag.urls[i])) {
                    return drag.urls[i].toString()
                }
            }
        }
        if (drag.hasText && isJsonUrl(drag.text)) {
            return drag.text
        }
        return ""
    }

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
            font.family: localFont.name
            font.pixelSize: 26
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    DropArea {
        id: dropData
        anchors.fill: parent
        onEntered: function(drag) {
                if (externalDrop.isSequenceDrag(drag) || !externalDrop.hasJsonFile(drag)) {
                    externalDrop.validFile = false
                    return
                }
                externalDrop.validFile = true
                drag.accept()
                externalDropText.text = "Drop "+ window.title + " preset here"
        }
        onExited: {
                externalDrop.validFile = false
        }
        onDropped: function(drop) {
            if (externalDrop.isSequenceDrag(drop)) {
                externalDrop.validFile = false
                return
            }
            const url = externalDrop.firstJsonUrl(drop)
            if (!url) {
                externalDrop.validFile = false
                return
            }
            if (drop.proposedAction == Qt.MoveAction || drop.proposedAction == Qt.CopyAction) {

                masterModel.data = fileDialogue.openFile(url).data
                masterModel.title = fileDialogue.openFile(url).title
                masterModel.load()

                drop.acceptProposedAction()
                externalDrop.validFile = false
            }
        }

    }

}
