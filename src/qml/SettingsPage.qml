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

    // Let's use the same background as in BrowserPage.qml.
    background: Rectangle { color: "white" }

    // A two-column layout with form elements and their labels.
    //   See file FormLayoutGallery.qml in application Kirigami Gallery for a usage example.
    Kirigami.FormLayout {

        ComboBox {
            id: languageChanger
            Kirigami.FormData.label: qsTr("User interface language:")
            textRole: "label" // Role of the model to show as the combobox list items.

            // Initialize the combobox with "no entry selected".
            //   This will be adapted in Component.onCompleted {} to select the current language.
            //   But choosing "-1" first is necessary, for whatever reason, to avoid a weird
            //   error in the Kirigami GlobalDrawer menu item to open this page: "GlobalDrawerActionItem.qml:132:
            //   TypeError: Cannot call method 'hasOwnProperty' of undefined"
            //
            //   TODO: Figure out the above error and report it as a bug to Kirigami.
            currentIndex: -1

            // Workaround for the Kirgami bug that the currentIndex element is shown white on white
            // in the ComboBox popup. Uses Kirigami's default colors for the same roles in a ListView.
            // About customizing a QQC2 ComboBox, see:
            //   https://doc.qt.io/qt-5/qtquickcontrols2-customize.html#customizing-combobox
            //   https://doc.qt.io/qt-5/qml-palette.html#qtquickcontrols2-palette
            // TODO: Report this bug, get it fixed, and remove this workaround.
            popup.palette.light:    "#7ba9c6" // Background of the popup's current item.
            popup.palette.midlight: "#308cc6" // Background of the popup's item while clicking.

            model: ListModel {
                id: languageModel

                // Languages are not automatically initialized from available .qm translation files
                // to be able to exclude languages with missing food rescue content translation.
                // Otherwise, this would result in no search results for that language.
                ListElement { label: qsTr("English"); language: "en" }
                // ListElement { label: qsTr("French");  language: "fr" } // Missing content translations.
                ListElement { label: qsTr("German");  language: "de" }
                // ListElement { label: qsTr("Spanish"); language: "es" } // Missing content translations.
            }

            Component.onCompleted: {
                console.log("SettingsPage.qml: Detected current locale: " + Qt.locale().name)
                var currentLanguage = Qt.locale().name.substring(0,2)
                console.log("SettingsPage.qml: Detected current language: " + currentLanguage)

                // Initialize the current item with the current UI language.
                //   TODO: When moving to Qt 5.14, replace this code with indexOfValue(). See:
                //   https://doc.qt.io/qt-5/qml-qtquick-controls2-combobox.html#indexOfValue-method
                //   That also requires setting valueRole, see:
                //   https://doc.qt.io/qt-5/qml-qtquick-controls2-combobox.html#valueRole-prop
                for (var i = 0; i < languageModel.count; i++) {
                    if (languageModel.get(i).language === currentLanguage) {
                        currentIndex = i
                        break
                    }
                }
            }

            onCurrentIndexChanged: {
                // Change the locale according to the new current entry.
                //   But don't change the locale if it's the same as the current locale. That condition
                //   applies when this event handler is called in Component.onCompleted. Changing the
                //   locale inside Component.onCompleted would change it while the KDE Kirigami
                //   GlobalDrawer menu is still open. And that leads to a weird error
                //   "GlobalDrawerActionItem.qml:132: ReferenceError: modelData is not defined", with
                //   the drawer staying open as a result.
                var currentLanguage = Qt.locale().name.substring(0,2)
                var nextLanguage = languageModel.get(currentIndex).language
                if (currentLanguage !== nextLanguage) {
                    // localeChanger is a custom context object made available in main.cpp.
                    localeChanger.changeLocale(nextLanguage)

                    // TODO: Also exchange the frontpage logo graphic with the proper i18n'ed version.
                    // That's a bit complicated though as we'd have to send a signal between two
                    // dynamically created QML objects. Better to make the logo graphic adapt itself
                    // according to locale changes, as indicated there as a TODO already.
                }
            }
        }
    }
}
