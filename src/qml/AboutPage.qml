import QtQuick 2.6
import org.kde.kirigami 2.6 as Kirigami

// Page for "☰ → About".
// Shows application meta info and the copyright notice.
Kirigami.AboutPage {
    // Data for the "About" dialog, in visual order.
    //   QML property values are written in JavaScript. This one contains just a JavaScript hash.
    //   That's why, different from QML, keys must be in double quotes and commas are required.
    aboutData: {

        // Header section.
        "displayName": "Food Rescue App",
        "version": "0.1",
        "shortDescription": qsTr("Helps you decide which food is still edible."),

        // "Copyright" section.
        // TODO: Fix that the "otherText" text will not be wrapped automatically. The usual solution
        //   of "Layout.fillWidth: true, wrapMode: Text.Wrap" on the Text {} object is not possible
        //   here because the corresponding QQ2.Label { } component in the Kirigami.AboutPage
        //   definition does not have an id that would allow overwriting it here. Needs overwriting
        //   the whole component and a bug report, probably.
        "otherText": qsTr("A convergent application available for Android, iOS, Plasma Mobile, Windows, Mac OS X and Linux."),
        "copyrightStatement": qsTr("© 2020 Matthias Ansorg"),
        "homepage": qsTr("https://fairdirect.org/food-rescue-app"), // Links to the correct translated version.
        "licenses": [ // TODO: Add all licenses, as that seems to be possible.
            {
                "name": qsTr("MIT Licencse"),
                "text": "", // TODO: To be added.
                "spdx": "MIT" // TODO: To be checked.
            }
        ],

        // "Authors" section.
        "authors": [
            {
                "name": "Matthias Ansorg",
                "task": "",
                "emailAddress": "matthias@ansorgs.de",
                "webAddress": "https://ma.juii.net/",
                "ocsUsername": ""
            }
        ],
        "credits": [],
        "translators": [],

        // Metadata not shown on the "About" page.
        "productName": "foodrescue-app",
        "componentName": "foodrescueapp",
        // TODO: Maybe this has to start with "org.kde."
        "desktopFileName": "org.fairdirect.foodrescue",
        // TODO: Find out if this works. It is meant to take an e-mail address.
        "bugAddress": "https://github.com/fairdirect/foodrescue-app/issues"
    }
}
