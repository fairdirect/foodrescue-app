import QtQuick 2.12
import QtQuick.Controls 2.12 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami

// Content of the main application window for the mobile version.
// (Same for the desktop version in BaseApp.qml, plus an added contextDrawer.)
BaseApp {
    id: root

    // TODO: What does this do? Do we need it?
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }
}
