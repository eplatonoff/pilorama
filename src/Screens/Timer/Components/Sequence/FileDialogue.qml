import QtQuick
import QtQuick.Dialogs
import QtCore

Item {
    id: fileDialogue
    anchors.fill: parent

    property var data: timerModel.data
    property var title: timerModel.title

    function openDialogue() {
        openFileDialog.open()
    }

    function saveDialogue() {
        saveFileDialog.open()
    }

    function getTitle(url) {
        var name = url.toString().replace(/\\/g, '/').replace(/.*\//, '').replace(/(.json)/, '')
        return name
    }

    function openFile(url) {
        var request = new XMLHttpRequest();
        request.open("GET", url, false);
        request.send(null)
        return {"title": getTitle(url), "data": request.responseText}
    }

    FileDialog {
        id: openFileDialog
        nameFilters: ["JSON files (*.json)"]
        defaultSuffix: 'json'
        fileMode: FileDialog.OpenFile
        currentFolder: StandardPaths.writableLocation(StandardPaths.DesktopLocation)

        onAccepted: {
            timerModel.data = openFile(openFileDialog.selectedFile).data
            timerModel.title = openFile(openFileDialog.selectedFile).title
            timerModel.load()
        }
    }

    FileDialog {
        id: saveFileDialog
        nameFilters: ["JSON files (*.json)"]
        fileMode: FileDialog.SaveFile
        currentFolder: StandardPaths.writableLocation(StandardPaths.DesktopLocation) + "/" + timerModel.title + '.json'

        onAccepted: {
            timerModel.save()
            const data = timerModel.data
            fileSaver.saveToFile(saveFileDialog.selectedFile.toString().substring(7), data)
        }
    }
}
