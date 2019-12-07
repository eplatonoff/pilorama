import QtQuick 2.13
import QtQuick.Dialogs 1.2

Item{

    id: fileDialogue
    anchors.fill: parent

    property var data: masterModel.data
    property var title: masterModel.title

    function openDialogue(){
        openFileDialog.open()
    }

    function saveDialogue(){
        saveFileDialog.open()
    }

    function getTitle(url){
        var name = url.toString().replace(/\\/g,'/').replace(/.*\//, '').replace(/(.json)/, '')
        return name
    }

    function openFile(url) {
        var request = new XMLHttpRequest();
        request.open("GET", url, false);
        request.send(null)
        return { "title" : getTitle(url) , "data": request.responseText }
    }

    function saveFile(url) {
        var request = new XMLHttpRequest();
        request.open("PUT", url, false);
        request.send(masterModel.data);
//        return request.status;
        return getTitle(url)
    }

    FileDialog {
        id: openFileDialog
        nameFilters: ["JSON files (*.json)"]
        selectMultiple: false

        onAccepted: {
            masterModel.data = openFile(fileUrl).data
            masterModel.title = openFile(fileUrl).title
            masterModel.load()
        }
    }

    FileDialog {
        id: saveFileDialog
        selectExisting: false
        nameFilters: ["JSON files (*.json)"]
        defaultSuffix : 'json'
        folder: 'file:///' + masterModel.title + ".json"

        onAccepted: {
            masterModel.save()
            masterModel.title = saveFile(fileUrl)
        }
    }
}
