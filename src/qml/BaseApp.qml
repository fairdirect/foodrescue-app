// The application depends on Qt 5.12.0, as provided by KDE Kirigami found in Ubuntu 20.04 LTS.
// See README.md for the reasoning. Correspondingly, requiring QtQuick versions up to 2.12 is
// allowed as per https://doc.qt.io/qt-5/qtquickcontrols-index.html#versions
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2

// The application depends on the Kirigami version provided in Ubuntu 20.04 LTS.
//
// TOOD Increase the version number to the version provided by Ubuntu 20.04 (by trial&error).
//   Ubuntu 19.10 provides 2.10, and Ubuntu 20.04 LTS may provide a higher version. Also
//   change this in all other QML files of the project.
import org.kde.kirigami 2.10

// Container for every control element the app has.
//   (Used as-is on desktop. For mobile, wrapped via MobileApp.qml.)
ApplicationWindow {
    id: root

    // The window title.
    title: "Food Rescue App"

    // Main content area.
    Component {
        id: mainPageComponent
        MainPage { } // See MainPage.qml.
    }

    pageStack.initialPage: mainPageComponent

    Component.onCompleted: {
        // Top-bar style "ToolBar" is not possible on mobile devices according to the
        // Kirigami Gallery App.
        //   Documentation: PageRow::globalToolBar, see https://api.kde.org/frameworks/kirigami/html/classorg_1_1kde_1_1kirigami_1_1PageRow.html#a8d9e50b817d9d28e9322f9a6ac75fc8d
        //   TOOD: Try to enable "ToolBar" style for tablets at least.
        if (Settings.isMobile)
            root.pageStack.globalToolBar.style = ApplicationHeaderStyle.Breadcrumb
        else
            root.pageStack.globalToolBar.style = ApplicationHeaderStyle.ToolBar

        // TODO: Fix that by default, the button style in the globalToolBar is
        // "Controls.Button.TextBesideIcon". We want "Controls.Button.IconOnly". See:
        // ActionToolBar::display, https://api.kde.org/frameworks/kirigami/html/classorg_1_1kde_1_1kirigami_1_1ActionToolBar.html#afe0cc7a3a7ee0522820d1225bed7cfc8
    }

    // Left sidebar drawer with the main menu.
    globalDrawer: GlobalDrawer {
        title: "Food Rescue"

        // TODO: Replace the icon with a circular, SVG version.
        titleIcon: "qrc:///images/secondfood-applogo-256x188.png"

        actions: [

            // TODO: Add a separator line here, to separate from any menu items above.
            Action {
                text: "History"
            },

            Action {
                text: "Bookmarks"
            },

            Action {
                text: "Settings"
                icon.name: "configure"
            },

            Action {
                separator: true
            },

            Action {
                text: "Help"
            },

            Action {
                text: "Feedback"
            },

            Action {
                text: "About"
                icon.name: "help-about"

                onTriggered: {
                    pageStack.layers.push(
                        Qt.resolvedUrl("AboutPage.qml")
                    );
                }
            },

            Action {
                text: "License Notes"
                icon.name: "help-about"
                onTriggered: {
                    pageStack.layers.push(
                        Qt.resolvedUrl("LicensePage.qml")
                    );
                }
            }

        ]
    }
}
