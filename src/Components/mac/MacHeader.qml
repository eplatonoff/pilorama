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
            anchors.leftMargin: -2
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: macHeaderTopOffset
            windowRef: macHeader.windowRef
            colors: macHeader.colors
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

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: macHeaderTotalHeight
        enabled: macHeaderEnabled
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true
        z: 0

        onPressed: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                windowRef.startSystemMove()
            }
        }
    }
}
