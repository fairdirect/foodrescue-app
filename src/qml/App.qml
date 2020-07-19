// The application depends on Qt 5.12.0, as provided by KDE Kirigami found in Ubuntu 20.04 LTS.
// See README.md for the reasoning. Correspondingly, requiring QtQuick versions up to 2.12 is
// allowed as per https://doc.qt.io/qt-5/qtquickcontrols-index.html#versions
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2

// The application depends on the Kirigami version provided in Ubuntu 20.04 LTS.
//
//   TOOD Increase the version number to the version provided by Ubuntu 20.04 (by trial&error).
//   Ubuntu 19.10 provides 2.10, and Ubuntu 20.04 LTS may provide a higher version. Also
//   change this in all other QML files of the project.
import org.kde.kirigami 2.10 as Kirigami


// Container for every control element the app has.
//   Used as-is on desktop. For mobile, wrapped via MobileApp.qml.
//
//   Qt Creator Note: In this file, "pageStack does not have members" and "icon does not have members"
//   are insight errors in Qt Creator and can be ignored. These seem to happen because Qt Creator for
//   some reason selects QtQuick ApplicationWindow in the editor insights. But the correct
//   Kirigami.ApplicationWindow is used when running the code.
Kirigami.ApplicationWindow {
    id: root

    // Displayed in the window title on desktop platforms.
    title: "Food Rescue App"

    // The main page, displaying food rescue content.
    pageStack.initialPage: BrowserPage { } // As implemented in BrowserPage.qml.

    // Set or restore the focus properly when showing a page or returning to a page.
    //   Source: https://stackoverflow.com/a/42299757 . Should workd, because MainPage also acts
    //   as a FocusScope. However, this does not work yet: after showing the "Scan" page and closing
    //   it, the focus is not restored to the addressBar's TextEdit.
    //   TODO: Fix that this does not yet have the desired effect. It might be due to behavior
    //   invoked when closing the "Scan" page.
    pageStack.onCurrentItemChanged: {
        root.pageStack.currentItem.forceActiveFocus()
    }

    Component.onCompleted: {
        // Top-bar style "ToolBar" is not possible on mobile devices according to the
        // Kirigami Gallery App.
        //   Documentation: PageRow::globalToolBar, see https://api.kde.org/frameworks/kirigami/html/classorg_1_1kde_1_1kirigami_1_1PageRow.html#a8d9e50b817d9d28e9322f9a6ac75fc8d
        //   TOOD: Try to enable "ToolBar" style for tablets.
        if (Kirigami.Settings.isMobile)
            root.pageStack.globalToolBar.style = Kirigami.ApplicationHeaderStyle.Breadcrumb
        else
            root.pageStack.globalToolBar.style = Kirigami.ApplicationHeaderStyle.ToolBar

        // TODO: Fix that by default, the button style in the globalToolBar is
        // "Controls.Button.TextBesideIcon". We want "Controls.Button.IconOnly". See:
        // ActionToolBar::display, https://api.kde.org/frameworks/kirigami/html/classorg_1_1kde_1_1kirigami_1_1ActionToolBar.html#afe0cc7a3a7ee0522820d1225bed7cfc8

        // Put a blinking cursor into the address bar of the initial page.
        //   This does not happen automatically through "focus: true" of the TextEdit because Page
        //   (and so also MainPage, which is a Kirigami.ScrollablePage) acts as a FocusScope as per
        //   https://doc.qt.io/qt-5/qtquickcontrols2-focus.html . And for a FocusScope,
        //   forceActiveFocus() is needed as per https://stackoverflow.com/a/43490143 .
        //   In addition, the same line has to be in addressBar.Component.onCompleted in MainPage.qml
        //   for some reason.
        root.pageStack.currentItem.forceActiveFocus()
    }

    // Left sidebar drawer with the main menu.
    globalDrawer: Kirigami.GlobalDrawer {
        title: "Food Rescue"

        // TODO: Replace the icon with a circular, SVG version.
        titleIcon: "qrc:///images/secondfood-applogo-256x188.png"

        actions: [
            Kirigami.Action {
                text: "History"
            },
            Kirigami.Action {
                text: "Bookmarks"
            },
            Kirigami.Action {
                text: "Settings"
                icon.name: "configure"
            },
            Kirigami.Action {
                separator: true
            },
            Kirigami.Action {
                text: "Help"
            },
            Kirigami.Action {
                text: "About"
                icon.name: "help-about"
                onTriggered: pageStack.layers.push(Qt.resolvedUrl("qrc:///qml/AboutPage.qml"))
            },
            Kirigami.Action {
                text: "License Notes"
                icon.name: "help-about"
                onTriggered: pageStack.layers.push(Qt.resolvedUrl("qrc:///qml/LicensePage.qml"))
            }
        ]
    }
}
