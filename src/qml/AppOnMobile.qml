import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami

// Content of the main application window for the mobile version.
//   (Same as the desktop version in BaseApp.qml, plus an added contextDrawer.)
App {
    id: root

    // TODO: The context drawer is not used yet in the application, so this can be removed.
    // TODO: If possible, merge this into BaseApp with a condition inside the QML.
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }
}
