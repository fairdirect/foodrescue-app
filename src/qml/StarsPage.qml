import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami

import QtQuick.Templates 2.4 as T

// Page for "☰ → Starred Articles".
//   TODO: Implement a bookmarks mechanism on this page, then re-enable the corresponding menu item.
Kirigami.ScrollablePage {
    id: starsPage
    title: qsTr("Starred Articles")
}
