import QtQuick 2.6
import org.kde.kirigami 2.6

// Page for "☰ → About".
// Shows application meta info and the copyright notice.
AboutPage {

    aboutData: {
        // Values in visual order in the "About" dialog.
        // Defining aboutData is special: keys must be in double quotes, commas are required.

        // Header section.
        "displayName": "Food Rescue App",
        "version": "0.1",
        "shortDescription": "Helps you decide which food is still edible.",

        // "Copyright" section.
        // TODO: Fix that the "otherText" text will not be wrapped automatically. The usual solution
        //   of "Layout.fillWidth: true, wrapMode: Text.Wrap" on the Text {} object is not possible
        //   here because the corresponding QQ2.Label { } component in the Kirigami.AboutPage
        //   definition does not have an id that would allow overwriting it here. Needs overwriting
        //   the whole component and a bug report, probably.
        "otherText": "A convergent application available for Android, iOS, Plasma Mobile, Windows, Mac OS X and Linux.",
        "copyrightStatement": "© 2020 Matthias Ansorg",
        "homepage": "https://fairdirect.org/food-rescue-app",
        "licenses": [ // TODO: Add all licenses, as that seems to be possible.
            {
                "name": "MIT Licencse",
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
        "desktopFileName": "org.fairdirect.foodrescue", // TODO: Maybe this has to start with "org.kde."
        // TODO: Find out if this works. It is meant to take an e-mail address.
        "bugAddress": "https://github.com/fairdirect/foodrescue-app/issues"
    }
}
