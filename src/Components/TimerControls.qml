import QtQuick

Item {
    id: button

    width: 130
    height: 34

    property string label: "Button"

    // All next properties are used only in split mode

    // When true shows reset and pause/resume buttons side by side
    property bool splitMode: false

    // Icons from the custom font
    property string resetIcon: "\uea12"
    property string runningIcon: "\uea14"
    property string stoppedIcon: "\uea13"

    property bool running: false

    property real iconSize: 22
    property bool togglePulsing: false

    // Emitted when either the reset button or the single start/reset button is clicked
    signal startResetClicked()
    // Emitted when the pause/resume button is clicked
    signal toggleClicked()

    state: splitMode ? "split" : "default"

    states: [
        State {
            name: "default"
            PropertyChanges {
                target: divider
                visible: false
                height: 0
                width: 0
            }
            PropertyChanges {
                target: resetButton
                visible: false
                opacity: 0
            }
            PropertyChanges {
                target: toggleButton
                visible: false
                opacity: 0
            }
        },
        State {
            name: "split"
            PropertyChanges {
                target: divider
                visible: true
                height: parent.height - 8
                width: 2
            }
            PropertyChanges {
                visible: true
                target: resetButton
                opacity: 1

            }
            PropertyChanges {
                visible: true
                target: toggleButton
                opacity: 1
            }
        }
    ]

    Rectangle {
        color: colors.getColor("lighter")
        radius: 22
        anchors.fill: parent

        // Single button mode
        MouseArea {
            id: startResetArea
            cursorShape: Qt.PointingHandCursor
            propagateComposedEvents: false
            visible: !button.splitMode
            anchors.fill: parent
            onPressed: button.startResetClicked()

            Text {
                id: buttonText
                text: button.label
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.fill: parent

                font.family: localFont.name
                font.pixelSize: 15

                color: colors.getColor("dark")

            }
        }

        Icon {
            id: resetButton
            propagateComposedEvents: false

            glyph: button.resetIcon

            width: parent.width / 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            color: colors.getColor("dark")
            size: button.iconSize

            onPressed: button.startResetClicked()
        }

        Rectangle {
            id: divider
            width: 0
            height: 0
            radius: 2

            color: colors.getColor("light")

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

        }

        Icon {
            id: toggleButton
            propagateComposedEvents: false

            glyph: button.running ? button.runningIcon : button.stoppedIcon

            width: parent.width / 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            size: button.iconSize

            color: colors.getColor("dark")

            onPressed: button.toggleClicked()

            Behavior on opacity { NumberAnimation { duration: 300 } }

            Timer {
                id: pulseTimer
                interval: 700
                running: button.togglePulsing
                repeat: true
                onTriggered: toggleButton.opacity = toggleButton.opacity === 1 ? 0.4 : 1
                onRunningChanged: if (!running) toggleButton.opacity = 1
            }
        }
    }
}
