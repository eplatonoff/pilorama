import QtQuick
import QtQuick.Controls.Fusion

import "../../../Components"

Item {
    id: theme

    anchors.left: parent.left
    anchors.right: parent.right
    height: 32

    Text {
        id: colorThemeLabel

        anchors.left: parent.left
        anchors.right: colorThemeDropdown.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        color: colors.getColor("dark")
        font.family: localFont.name
        font.pixelSize: 16
        renderType: Text.NativeRendering
        text: qsTr("Theme")
    }
    ComboBox {
        id: colorThemeDropdown

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.top: parent.top
        currentIndex: {
            const index = colorThemeDropdown.model.indexOf(appSettings.colorTheme);
            return index !== -1 ? index : 0;
        }
        model: ["Light", "Dark", "System"]
        palette.buttonText: colors.getColor("dark")
        width: 90

        background: Rectangle {
            color: "transparent"

            border {
                color: "#00FFFFFF"
                width: 1
            }
        }
        contentItem: Text {
            color: colors.getColor("dark")
            font.family: localFont.name
            font.pixelSize: 16
            horizontalAlignment: Text.AlignLeft
            leftPadding: 0
            renderType: Text.NativeRendering
            rightPadding: colorThemeDropdown.indicator.width
            text: colorThemeDropdown.displayText
            verticalAlignment: Text.AlignVCenter
        }
        indicator: Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
            height: 24
            width: 24

            FaIcon {
                id: dropDownButton

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf150"

                onReleased: {
                    colorThemeDropdown.popup.open();
                }
            }
        }

        onActivated: {
            appSettings.colorTheme = colorThemeDropdown.currentText;
        }
    }
}
