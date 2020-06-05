import QtQuick 2.12
import QtQuick.Controls 2.12 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami

// Page shown at startup of the application.
// Shows the main area of the application, which contains every control element except the sidebar
// drawer and any layers / drawers added on top.
Kirigami.Page {

    // TODO: Why does the SwipeView stop working if this is different from "page"?
    id: page

    // Page title, currently not shown as Controls.Page does not show titles.
    // TODO: Set the title as suitable for the tab contents, such as "Search product" for "Search".
    // title: "Food Rescue"

    // Area for all the app's changing content.
    Controls.SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex
        clip: true

        Repeater {
            model: 3

            // Tab content.
            Item {
                Controls.Label {
                    width: parent.width
                    wrapMode: Controls.Label.Wrap
                    horizontalAlignment: Qt.AlignHCenter
                    text: "Page " + modelData
                }
            }
        }
    }

    // Footer tabbar, the main navigation element.
    footer: Controls.TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        Controls.TabButton {
            text: "Search"
        }
        Controls.TabButton {
            text: "Rescue"
        }
        Controls.TabButton {
            text: "History"
        }
    }
}
