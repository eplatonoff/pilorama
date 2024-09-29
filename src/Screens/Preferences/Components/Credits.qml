import QtQuick

import "../../../Components"

Item {
    id: credits

    anchors.fill: parent

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: 24
        spacing: 4

        Icon {
            id: github

            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor('mid')
            glyph: "\uea03"
            size: 16

            onReleased: {
                Qt.openUrlExternally("https://github.com/eplatonoff/pilorama/releases");
            }
        }
        Text {
            id: version

            anchors.verticalCenter: parent.verticalCenter
            color: colors.getColor('mid')
            font.family: localFont.name
            text: Qt.application.version

            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
