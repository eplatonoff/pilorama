import QtQuick
import QtQuick.Controls

import "Components"
import "../../Components"

Item {
    id: container
    visible: false

    Item {
        id: content

        anchors.fill: parent
        anchors.margins: 16

        Header {
            id: header
        }

        Column {
            id: settings

            spacing: 8

            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 16

            property bool splitToSequence: false
            property bool splitToSequence2: false

            Setting {
                label: qsTr("Split timer to sequence")
                checked: settings.splitToSequence
                onReleased: {
                    settings.splitToSequence = !settings.splitToSequence
                }
            }

            Setting {
                label: qsTr("Run away")
                checked: settings.splitToSequence2
                onReleased: {
                    settings.splitToSequence2 = !settings.splitToSequence2
                }
            }
        }
    }
}
