import QtQuick
import QtQuick.Dialogs
import QtCore

Item {
    id: fileDialogue

    property var data: timerModel.data
    property var title: timerModel.title

    function getTitle(url) {
        var name = url.toString().replace(/\\/g, '/').replace(/.*\//, '').replace(/(.json)/, '');
        return name;
    }
    function openDialogue() {
        openFileDialog.open();
    }
    function openFile(url) {
        var request = new XMLHttpRequest();
        request.open("GET", url, false);
        request.send(null);
        return {
            "title": getTitle(url),
            "data": request.responseText
        };
    }
    function saveDialogue() {
        saveFileDialog.open();
    }

    anchors.fill: parent

    FileDialog {
        id: openFileDialog

        currentFolder: StandardPaths.writableLocation(StandardPaths.DesktopLocation)
        defaultSuffix: 'json'
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON files (*.json)"]

        onAccepted: {
            timerModel.data = openFile(openFileDialog.selectedFile).data;
            timerModel.title = openFile(openFileDialog.selectedFile).title;
            timerModel.load();
        }
    }
    FileDialog {
        id: saveFileDialog

        currentFolder: StandardPaths.writableLocation(StandardPaths.DesktopLocation) + "/" + timerModel.title + '.json'
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON files (*.json)"]

        onAccepted: {
            timerModel.save();
            const data = timerModel.data;
            fileSaver.saveToFile(saveFileDialog.selectedFile.toString().substring(7), data);
        }
    }
}
