import QtQuick

import "../../../Components"

Item {
    id: credits

    anchors.fill: parent

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4
        height: 24

        Text {
            id: version

            anchors.verticalCenter: parent.verticalCenter

            font.family: localFont.name
            color: colors.getColor('mid')

            text: Qt.application.version

            onLinkActivated: Qt.openUrlExternally(link)
        }

        Icon {
            id: github
            color: colors.getColor('mid')
            anchors.verticalCenter: parent.verticalCenter
            glyph: "\uea03"
            size: 16

            onReleased: {
                Qt.openUrlExternally("https://github.com/eplatonoff/pilorama/releases")
            }
        }
    }
}
