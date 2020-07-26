import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami

import QtQuick.Templates 2.4 as T

// Page for "☰ → Settings".
Kirigami.ScrollablePage {
    id: page
    title: qsTr("Settings")
    Layout.fillWidth: true

    // A two-column layout with form elements and their labels.
    //   See file FormLayoutGallery.qml in application Kirigami Gallery for a usage example.
    Kirigami.FormLayout {

        ComboBox {
            id: languageChanger

            // Workaround for the Kirgami bug that the currentIndex element is shown white on white
            // in the ComboBox popup. Uses Kirigami's default colors for the same roles in a ListView.
            // TODO: Report this bug, get it fixed, and remove this workaround.
            popup.palette.light:    "#7ba9c6" // Background of the popup's current item.
            popup.palette.midlight: "#308cc6" // Background of the popup's item while clicking.

            Kirigami.FormData.label: qsTr("User interface language:")
            textRole: "text" // Role of the model to show as the combobox list items.

            // TODO: The following will show the combobox initially empty whenever opening the
            // settings page. Change this to show the entry cooresponding to the current locale.
            currentIndex: -1
            onCurrentIndexChanged: {
                console.debug("Language switching to: " + languageModel.get(currentIndex).language)
                // localeChanger is a custom context object provided in main.cpp.
                localeChanger.changeLanguage(languageModel.get(currentIndex).language)
            }

            model: ListModel {
                id: languageModel
                ListElement { text: qsTr("English"); language: "en" }
                ListElement { text: qsTr("German");  language: "de" }
            }
        }

    }
}
