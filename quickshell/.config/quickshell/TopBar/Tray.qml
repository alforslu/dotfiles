import QtQuick
import QtQuick.Controls.Basic
import Quickshell.Hyprland
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import ".."

Repeater {
    model: SystemTray.items

    delegate: Button {
        id: trayButton
        required property SystemTrayItem modelData

        implicitWidth: 28
        implicitHeight: Theme.defaultBackgroundHeight
        padding: 4
        topInset: 2
        bottomInset: 2
        Accessible.name: modelData.title

        onClicked: {
            if (modelData.onlyMenu) {
                if (modelData.hasMenu)
                    trayMenu.open();
            } else {
                modelData.activate();
            }
        }

        background: Rectangle {
            radius: height / 2
            color: trayButton.down ? Theme.pressedColor : trayButton.hovered ? Theme.hoverColor : "transparent"

            border.width: trayButton.visualFocus ? 1 : 0
            border.color: Theme.textColor
        }

        contentItem: IconImage {
            source: trayButton.modelData.icon
            implicitSize: 16
        }

        QsMenuAnchor {
            id: trayMenu
            menu: trayButton.modelData.menu
            anchor.item: trayButton
            anchor.edges: Edges.Bottom
            anchor.gravity: Edges.Bottom
        }

        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: {
                if (trayButton.modelData.hasMenu)
                    trayMenu.open();
            }
        }
    }
}
