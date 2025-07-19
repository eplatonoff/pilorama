import QtQuick
import QtQuick.Dialogs
import QtCore

Item{

    id: fileDialogue
    anchors.fill: parent

    property var data: masterModel.data
    property var title: masterModel.title

    function openDialogue(){
        if (Qt.platform.os !== "wasm")
            openFileDialog.open()
    }

    function saveDialogue(){
        if (Qt.platform.os !== "wasm")
            saveFileDialog.open()
    }

    function getTitle(url){
        var name = url.toString().replace(/\\/g,'/').replace(/.*\//, '').replace(/(.json)/, '')
        return name
    }

    function openFile(url) {
        if (Qt.platform.os === "wasm")
            return { title: "", data: "" }

        var request = new XMLHttpRequest();
        request.open("GET", url, false);
        request.send(null)
        return { "title" : getTitle(url) , "data": request.responseText }
    }

    function saveFile(url) {
        if (Qt.platform.os === "wasm")
            return ""

        var request = new XMLHttpRequest();
        request.open("PUT", url, true); // async false created empty files on macos
        request.send(masterModel.data);
        return getTitle(url)
    }

    FileDialog {
        id: openFileDialog
        visible: Qt.platform.os !== "wasm"
        nameFilters: ["JSON files (*.json)"]
        currentFolder: StandardPaths.writableLocation(StandardPaths.DesktopLocation)

        onAccepted: {
            masterModel.data = openFile(selectedFile).data
            masterModel.title = openFile(selectedFile).title
            masterModel.load()
        }
    }

    FileDialog {
        id: saveFileDialog
        visible: Qt.platform.os !== "wasm"
        fileMode: FileDialog.SaveFile
        nameFilters: ["JSON files (*.json)"]
        defaultSuffix : 'json'
        currentFolder: StandardPaths.writableLocation(StandardPaths.DesktopLocation) + "/" + masterModel.title + '.json'

        onAccepted: {
            masterModel.save()
            masterModel.title = saveFile(selectedFile)
        }
    }
}
