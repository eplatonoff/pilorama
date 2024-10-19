import QtQuick

Item {
    id: rectangle

    anchors.left: parent.left
    anchors.margins: 16
    anchors.right: parent.right
    anchors.top: parent.top
    height: 24

    Image {
        id: logo

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: appSettings.darkMode ? "qrc:/assets/img/white-logo.svg" : "qrc:/assets/img/dark-logo.svg"
    }
    MacWindowControls {
        id: macWindowControls

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: Qt.platform.os === "osx"
    }
    Rectangle {
        id: border

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: logo.bottom
        anchors.topMargin: 16
        color: colors.getColor("light")
        height: 0.5
    }
}
