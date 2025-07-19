import QtQuick

QtObject {
    // Stub for platforms without file system access
    function openDialogue() {}
    function saveDialogue() {}
    function openFile(url) { return { title: "", data: "" } }
    function saveFile(url) { return "" }
}
