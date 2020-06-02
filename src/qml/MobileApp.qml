import QtQuick 2.1
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami

// Content of the main application window for the mobile version.
// (Same for the desktop version in BaseApp.qml, plus an added contextDrawer.)
BaseApp {
    id: root

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }
}
