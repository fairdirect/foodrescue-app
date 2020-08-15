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

    // Let's use the same background as in BrowserPage.qml.
    background: Rectangle { color: "white" }

    Text {
        id: licenseNotes

        Layout.fillWidth: true
        textFormat: Text.RichText // Otherwise we get Text.StyledText, offering much fewer options.
        wrapMode: Text.Wrap
        onLinkActivated: Qt.openUrlExternally(link)

        // License notes text.
        //   Do not use multi-line string literals in qsTr() as these will be uncomfortable to read in
        //   translation software due to the excess whitespace from indentation.
        text:
            '<html>' +

            '<head><style>
                h2 { font-weight: normal; margin-top: 32px; }
                p  { margin-left: 16px; }
            </style></head>' +

            qsTr(
                '<p>Food Rescue App is free software. You can copy, modify and distribute ' +
                '<a href="https://github.com/fairdirect/foodrescue-app">its source code</a> under the ' +
                'terms of the <a href="https://github.com/fairdirect/foodrescue-app/blob/master/LICENSE.md">MIT ' +
                'Licence</a>.</p>'
            ) +
            qsTr(
                '<p>Binary versions of Food Rescue App, as used for installation on your computer or mobile ' +
                'device, also contain third-party software and data used under open source and open data ' +
                'licenses, as detailed below.</p>'
            ) +

            qsTr('<h2>1. Open Food Facts</h2>') +
            qsTr(
                // This Open Food Facts license note is as required by OdBL sections 4.2 and 4.3.
                '<p>Our database is a derivative database of <a href="https://openfoodfacts.org/">Open ' +
                'Food Facts</a>, which is made available here under the ' +
                '<a href="https://opendatacommons.org/licenses/odbl/1.0/">Open Database License ' +
                'v1.0</a>. Individual contents of the database are available under the ' +
                '<a href="https://opendatacommons.org/licenses/dbcl/1.0/">Database Contents License</a>.</p>'
            ) +
            qsTr(
                '<p>Our re-use of Open Food Facts data is additionally governed by the Open Food ' +
                'Facts <a href="https://world.openfoodfacts.org/terms-of-use">Terms of use, ' +
                'contribution and re-use</a>, specifically the sections "General terms and ' +
                'conditions" and "Terms and conditions for re-use".</p>'
            ) +

            qsTr('<h2>2. Qt</h2>') +
            qsTr(
                '<p>This program uses the <a href="https://www.qt.io/">Qt framework</a> under the terms of the ' +
                '<a href="https://www.gnu.org/licenses/lgpl-3.0.html">GNU Lesser General Public License version 3</a> ' +
                'as published by the Free Software Foundation. The Qt framework is copyrighted by The Qt Company Ltd.</p>'
            ) +
            qsTr(
                '<p>To fulfill the requirements of Qt\'s LGPL v3 licence, the source code and compilation instructions ' +
                'of this program are available in the Github repository' +
                '<a href="https://github.com/fairdirect/foodrescue-app">fairdirect/foodrescue-app</a>.</p>'
            ) +
            qsTr(
                '<p>The Qt framework contains multiple third-party libraries, licenced under various free software ' +
                'licences. For the full list, see <a href="https://doc.qt.io/qt-5/licenses-used-in-qt.html">Licenses ' +
                'Used in Qt</a>.</p>'
            ) +
            qsTr(
                // For details about the legal opinion in this paragraph, see README.md.
                '<p>The Qt framework also contains <a href="https://doc.qt.io/qt-5/qtmodules.html#gpl-licensed-addons">some ' +
                'add-ons</a> licenced under the GNU General Public License v3. No distribution of this program (neither ' +
                'in source nor binary form) contains their code, and this program is not designed to use any of these ' +
                'add-ons since it does not contain any code using them. Due to this, the fact of being able to use this ' +
                'program with GPL\'ed add-ons at runtime does not force this program to use a GPL-compatible licence. Still, ' +
                'this program uses the MIT licence, which is compatible with the GPL v3.</p>'
            ) +

            qsTr('<h2>3. Kirigami</h2>') +
            qsTr(
                '<p>This program uses <a href="https://kde.org/products/kirigami/">KDE Kirigami</a>, a framework ' +
                'for developing mobile-desktop convergent applications, building on Qt Quick. Kirigami is licensed ' +
                'under the <a href="https://invent.kde.org/frameworks/kirigami/-/blob/master/LICENSE.LGPL-2">LGPL ' +
                'v2 license</a>.</p>'
            ) +

            qsTr('<h2>4. ZXing-C++</h2>') +
            qsTr(
                '<p>This program uses <a href="https://github.com/nu-book/zxing-cpp">ZXing-C++</a>, the most mature ' +
                'C++ version of the well-known barcode scanner library ZXing. It is licensed under the ' +
                '<a href="https://github.com/nu-book/zxing-cpp/blob/master/LICENSE.ZXing">Apache License Version 2.0</a>.</p>'
            ) +

            qsTr('<h2>5. QZXingNu</h2>') +
            qsTr(
                '<p>This program uses a forked version of <a href="https://github.com/swex/QZXingNu">QZXingNu</a>, ' +
                'an interface to the ZXing-C++ barcode scanner for QML applications. It is licensed under the ' +
                '<a href="http://www.apache.org/licenses/LICENSE-2.0">Apache License Version 2.0</a>.</p>'
            ) +

            qsTr('<h2>6. GCC Runtime Library</h2>') +
            qsTr(
                '<p>This program may contain the GCC runtime libraries in its distributed format. ' +
                'This code is licensed under the <a href="https://www.gnu.org/licenses/gcc-exception-3.1.en.html">GCC ' +
                'Runtime Library Exception</a>, which means that there is no obligation for this program to be ' +
                'distributed under a GPLv3-compatible licence. Even so, this program uses MIT licence at the current ' +
                'time, which is compatible with the GPL v3 licence.</p>'
             ) +

            qsTr('<h2>7. LLVM Runtime Library</h2>') +
            qsTr(
                '<p>This program may contain the LLVM runtime libraries in its distributed format. ' +
                'This code is licensed under the <a href="https://releases.llvm.org/9.0.0/LICENSE.TXT">Apache ' +
                'License v2.0 with LLVM Exceptions</a>.</p>'
            ) +

            '</html>'

        // Show a hand cursor when mousing over hyperlinks.
        //   Source: https://blog.shantanu.io/2015/02/15/creating-working-hyperlinks-in-qtquick-text/
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton // Don't eat clicks on the Text.
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }
}
