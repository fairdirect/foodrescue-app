import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10

// Page for "☰ → Settings".
ScrollablePage {
    id: page
    title: qsTr("Settings")
    Layout.fillWidth: true

    // Language switcher.
    //   langSwitcher is a custom context object provided in main.cpp.
    RowLayout {
        Button {
            id: langButtonEn
            text: "En"
            onClicked: {
                console.log("SettingsPage: langButtonEn: 'clicked()' received")
                localeChanger.changeLanguage("en");
            }
        }

        Button {
            id: langButtonDe
            text: "De"
            onClicked: {
                console.log("SettingsPage: langButtonDe: 'clicked()' received")
                localeChanger.changeLanguage("de");
            }
        }
    }

}
