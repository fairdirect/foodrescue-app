import QtQuick 2.1
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami

// Content of the main application window.
// (Used as-is on desktop. For mobile, wrapped via MobileApp.qml.)
Kirigami.ApplicationWindow {
    id: root

    // Main content area.
    pageStack.initialPage: mainAreaComponent
    Component {
        id: mainAreaComponent
        MainArea {} // See MainArea.qml.
    }

    // Left sidebar drawer with the menu.
    globalDrawer: Kirigami.GlobalDrawer {
        title: "Global Drawer"
        titleIcon: "applications-graphics"

        actions: [
            Kirigami.Action {
                text: "Menu Entry"
                icon {
                    name: "configure"
                    color: Kirigami.Theme.activeTextColor
                }
            }
        ]
    }
}
