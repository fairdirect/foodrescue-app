// The application depends on Qt 5.12.0, as provided by KDE Kirigami found in Ubuntu 20.04 LTS.
// See README.md for the reasoning. Correspondingly, requiring QtQuick versions up to 2.12 is
// allowed as per https://doc.qt.io/qt-5/qtquickcontrols-index.html#versions
import QtQuick 2.12
import QtQuick.Controls 2.12 as Controls
import QtQuick.Layouts 1.2

// The application depends on the Kirigami version provided in Ubuntu 20.04 LTS.
//
// TOOD Increase the version number to the version provided by Ubuntu 20.04 (by trial&error).
//   Ubuntu 19.10 provides 2.10, and Ubuntu 20.04 LTS may provide a higher version. Also
//   change this in all other QML files of the project.
import org.kde.kirigami 2.10 as Kirigami

// Container for every control element the app has.
//   (Used as-is on desktop. For mobile, wrapped via MobileApp.qml.)
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
        title: "Food Rescue"

        // TODO: Replace the icon with a circular, SVG version.
        titleIcon: "qrc:///images/secondfood-applogo-256x188.png"

        actions: [

            // TODO: Add a separator line here, to separate from any menu items above.
            Kirigami.Action {
                text: "Warnings"
                icon {
                    name: "dialog-warning"
                }
            },

            Kirigami.Action {
                separator: true
            },

            Kirigami.Action {
                text: "Settings"
                icon {
                    name: "configure"
                }
            },

            Kirigami.Action {
                text: "Help"
                icon {
                    name: "help-about"
                }
            },

            Kirigami.Action {
                text: "About this App"
            }
        ]
    }
}
