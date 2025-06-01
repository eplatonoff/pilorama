import QtQuick

Item{
    id: button

    width: 130
    height: 34

    property string label: 'Button'
    property bool splitMode: false
    property string leftIcon: "O"
    property string rightIcon: ">"
    property real iconSize: 22

    signal clicked()
    signal leftClicked()
    signal rightClicked()

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
                target: leftButton
                visible: false
                opacity: 0
            }
            PropertyChanges {
                target: rightButton
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
                target: leftButton
                opacity: 1

            }
            PropertyChanges {
                visible: true
                target: rightButton
                opacity: 1
            }
        }
    ]

    // transitions: [
    //     Transition {
    //         from: "*"
    //         to: "*"
    //         NumberAnimation {
    //             properties: "height, opacity";
    //             duration: 1000
    //             easing.type: Easing.OutQuad
    //         }
    //     }
    // ]


    Rectangle {
        color: colors.getColor("lighter")
        radius: 22
        anchors.fill: parent

        // Single button mode
        MouseArea {
            id: startButton
            propagateComposedEvents: false
            visible: !button.splitMode
            anchors.fill: parent
            onClicked: button.clicked()

            Text {
                id: buttonText
                visible: !button.splitMode
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
            id: leftButton
            propagateComposedEvents: false

            glyph: button.leftIcon

            width: parent.width / 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            color: colors.getColor("dark")
            size: button.iconSize

            onReleased: button.leftClicked()
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
            id: rightButton
            propagateComposedEvents: false

            glyph: button.rightIcon

            width: parent.width / 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            size: button.iconSize

            color: colors.getColor("dark")

            onReleased: button.rightClicked()
        }


    }


}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
