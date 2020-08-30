import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami

// Demonstrates the Kirigami 2.10 bug that custom icons are not shown for page actions.
//
// Page actions work with theme icons (see "rightAction:"), but not with custom icons
// (see "leftAction:"). Even when using the exact same action that successfully displays the custom
// icon on a button (see "ToolButton").
Kirigami.ApplicationWindow {
    pageStack.initialPage: Kirigami.Page {
        title: "Icon Problem Demo"

        Kirigami.Action {
            id: action1
            text: "Action 1"
            iconSource: "file:/home/matthias/Projects/Fairdirect.Food_Rescue_App/Repo.foodrescue-app/src/images/barcode-64x64.png"
        }

        Kirigami.Action {
            id: action2
            text: "Action 2"
            iconName: "camera-web"
        }

        leftAction: action1
        rightAction: action2
        ToolButton { action: action1 }
    }
}
