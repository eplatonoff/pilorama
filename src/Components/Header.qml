import QtQuick


Item {
    id: rectangle

    anchors.top: parent.top
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.margins: 16
    height: 24

    Image {
        id: logo

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        source: appSettings.darkMode ? "qrc:/assets/img/white-logo.svg" : "qrc:/assets/img/dark-logo.svg"
    }

    MacWindowControls {
        id: macWindowControls
        visible: Qt.platform.os === "osx"

        anchors.left: parent.left

        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: border

        anchors.top: logo.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.right: parent.right
        height: 0.5
        color: colors.getColor("light")
    }
}
