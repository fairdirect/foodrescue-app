import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami

// Page for "☰ → License Notes".
// Shows required licence information.
Kirigami.ScrollablePage {
    id: page
    title: qsTr("License Notes")
    Layout.fillWidth: true

    Text {
        id: licenseNotes

        // License notes text.
        //   The Open Food Facts license note is as required by OdBL sections 4.2 and 4.3.
        //   Do not use multi-line string literals as these will be uncomfortable to read in
        //   translation software.
        text:
            '<html>' +

            qsTr(
              '<p>Food Rescue App is free software. You can copy, modify and distribute ' +
                '<a href="https://github.com/fairdirect/foodrescue-app">its source code</a> under the ' +
                'terms of the <a href="https://github.com/fairdirect/foodrescue-app/blob/master/LICENSE.md">MIT' +
                'licence</a>.</p>'
            ) +
            qsTr(
              '<p>Installable packages of Food Rescue App also contain third-party software and data ' +
                'used under open source licences, as detailed below.</p>'
            ) +

            qsTr(
              '<h2>Open Food Facts</h2>'
            ) +
            qsTr(
              '<p>The database is a derivative database of <a href="https://openfoodfacts.org/">Open ' +
                'Food Facts</a>, which is made available here under the ' +
                '<a href="https://opendatacommons.org/licenses/odbl/1.0/">Open Database License ' +
                'v1.0</a>. Individual contents of the database are available under the ' +
                '<a href="https://opendatacommons.org/licenses/dbcl/1.0/">Database Contents License</a>.</p>'
            ) +
            qsTr(
              '<p>Our re-use of Open Food Facts data is also additionally governed by the Open Food ' +
                'Facts <a href="https://world.openfoodfacts.org/terms-of-use">Terms of use, ' +
                'contribution and re-use</a>, specifically the sections "General terms and ' +
                'conditions" and "Terms and conditions for re-use".</p>'
            ) +

            qsTr('<h2>Qt</h2>') +
            qsTr('<p>TODO</p>') +

            qsTr('<h2>GCC Runtime Library</h2>') +
            qsTr('<p>TODO</p>') +

            qsTr('<h2>CLang Runtime Library</h2>') +
            qsTr('<p>TODO</p>') +

            '</html>'

        Layout.fillWidth: true
        wrapMode: Text.Wrap
        onLinkActivated: Qt.openUrlExternally(link)

        // Show a hand cursor when mousing over hyperlinks.
        // Source: https://blog.shantanu.io/2015/02/15/creating-working-hyperlinks-in-qtquick-text/
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton // Don't eat clicks on the Text.
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }
}
