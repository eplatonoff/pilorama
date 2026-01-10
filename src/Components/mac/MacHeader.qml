import QtQuick

Item {
    id: macHeader

    required property var windowRef
    required property var appSettings
    required property var colors
    required property bool macHeaderEnabled

    property int macTitlebarHeight: macHeaderEnabled ? 20 : 0
    property int macHeaderSpacing: macHeaderEnabled ? 10 : 0
    property int macHeaderTopOffset: macHeaderEnabled ? 8 : 0
    property int macHeaderTotalHeight: macHeaderEnabled
                                      ? macTitlebarHeight + macHeaderSpacing
                                      : 0

    height: macTitlebarHeight
    visible: macHeaderEnabled
    z: 1

    Item {
        id: headerContent

        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        z: 1

        Image {
            id: headerLogo

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: macHeaderTopOffset
            height: 16
            fillMode: Image.PreserveAspectFit
            source: appSettings.darkMode
                    ? "qrc:/assets/img/white-logo.svg"
                    : "qrc:/assets/img/dark-logo.svg"
            visible: macHeaderEnabled
        }

        MacWindowControls {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: macHeaderTopOffset
            visible: macHeaderEnabled
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: headerLogo.bottom
            anchors.topMargin: macHeaderSpacing
            height: 0.5
            color: colors.getColor("light")
            visible: macHeaderEnabled
        }
    }

    MouseArea {
        id: windowDragArea

        property point origin: Qt.point(0, 0)

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: macHeaderTotalHeight
        enabled: macHeaderEnabled
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true
        z: 0

        onPositionChanged: (mouse) => {
            if (mouse.buttons & Qt.LeftButton) {
                const delta = Qt.point(mouse.x - origin.x, mouse.y - origin.y)
                windowRef.x += delta.x
                windowRef.y += delta.y
            }
        }
        onPressed: (mouse) => {
            origin = Qt.point(mouse.x, mouse.y)
        }
    }
}
