import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10

// Content of the main application window for the mobile version.
//   (Same as the desktop version in BaseApp.qml, plus an added contextDrawer.)
BaseApp {
    id: root

    // TODO: What does this do? Do we need it?
    // TODO: If possible, merge this into BaseApp with a condition inside the QML.
    contextDrawer: ContextDrawer {
        id: contextDrawer
    }
}
