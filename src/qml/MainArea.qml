import QtQuick 2.1
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami

Kirigami.ScrollablePage {
    id: pageRoot

    title: qsTr("Empty App")

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
    }
    implicitWidth: Kirigami.Units.gridUnit * 12 // Subdivides available for sizing things.

    ListView {
        id: mainAreaList

        currentIndex: -1 // Don't show any list item as "selected".
        focus: true

        model: ListModel {
            ListElement {
                text: qsTr("List Item 1")
            }
            ListElement {
                text: qsTr("List Item 2")
            }
            ListElement {
                text: qsTr("List Item 3")
            }
        }

        delegate: Kirigami.BasicListItem {
            id: listItem
            label: model.text
            highlighted: focus && ListView.isCurrentItem
            checked: mainAreaList.openPageIndex === index
        }
    }
}
