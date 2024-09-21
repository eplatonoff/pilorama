import QtQuick

import "../../../Components"

Rectangle {
    id: rectangle

    anchors.top: parent.top
    anchors.right: parent.right
    anchors.left: parent.left
    height: 24

    color: "transparent"

    Image {
        id: logo

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        source: appSettings.darkMode ? "qrc:/assets/img/white-logo.svg" : "qrc:/assets/img/dark-logo.svg"
    }

    FaIcon {
        id: preferencesButton

        anchors.right: Qt.platform.os === "osx" ? parent.right : undefined
        anchors.left: Qt.platform.os !== "osx" ? parent.left : undefined

        anchors.verticalCenter: parent.verticalCenter

        glyph: "\uf0c9"

        onReleased: {
            stack.push(preferences);
        }
    }

    MacWindowControls {
        id: macWindowControls
        visible: Qt.platform.os === "osx"

        anchors.left: parent.left

        anchors.verticalCenter: parent.verticalCenter
    }

}
