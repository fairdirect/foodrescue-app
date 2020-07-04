import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami
import local 1.0 as Local // Our custom QML components, as exported in main.cpp.

// Page shown at startup of the application.
//   Shows the main area of the application, which contains every control element except the
//   sidebar drawer and any layers / sheets / drawers added on top.
//
//   TODO: Rename this component from MainPage to ContentBrowser.
Kirigami.ScrollablePage {
    id: mainPage

    // Page title.
    // TODO: Set the title as suitable for current window contents.
    title: "Food Rescue"

    Layout.fillWidth: true
    keyboardNavigationEnabled: true
    horizontalScrollBarPolicy: ScrollBar.AlwaysOff


    // Wraps a database search and returns the result or a "nothing found" message.
    function contentOrMessage(searchTerm) {
        var content = database.content(searchTerm)
        if (content === "")
            // TODO: i18n this message properly.
            return "No content found for \"" + searchTerm + "\"."
        else
            return content
    }


    // Event handler for a dynamically created ScannerPage object.
    function onBarcodeFound(code) {
        console.log("mainPage: 'barcodeFound()' signal, code = " + code)
        addressBar.text = code
        browserContent.text = contentOrMessage(code)
    }


    // Interface to the food rescue content.
    //   This is a C++ defined QML type, see ContentDatabase.h. Interface: method content(string).
    //   Note that this is not the same ContentDatabase object that is created in main.cpp. It still
    //   works because we rely on the QSqlDatabase default connection, see ContentDatabase.cpp for
    //   details.
    Local.ContentDatabase {
        id: database
    }

    // Define the page toolbar's contents.
    //   A toolbar can have left / main / right / context buttons. The read-only property
    //   org::kde::kirigami::Page::globalToolBarItem refers to this toolbar.
    actions {
        left: Kirigami.Action {
            iconName: "go-previous"
            text: "Page Back"
            onTriggered: {
                showPassiveNotification("Go back action triggered")
            }
        }

        // No main action needed so far.
        // main: Kirigami.Action { }

        right: Kirigami.Action {
            iconName: "go-next"
            text: "Page Forward"
            onTriggered: {
                showPassiveNotification("Go forward action triggered")
            }
        }

        // No contextual actions so far.
        // contextualActions: [ ]
    }

    ColumnLayout {
        // Since a Kirigami Page is a Layout, don't use anchors here. Instead:
        Layout.fillWidth: true

        spacing: 10

        // Browser header bar: adress bar, "Go" button, "Scan" button.
        RowLayout {
            Layout.fillWidth: true

            TextField {
                id: addressBar
                Layout.fillWidth: true
                focus: true

                placeholderText: "barcode number"

                // Disable predictive text input to make textEdited() signals work under Android.
                //   A workaround for multiple Qt bugs. See: https://stackoverflow.com/a/62526369
                inputMethodHints: Qt.ImhSensitiveData

                onTextChanged: {
                    console.log("addressBar: 'textChanged()' signal")
                    goButton.enabled = text.length > 0 ? true : false
                }

                // Handle the "text accepted" event.
                //   This event is emitted when the user finishes editing the text field.
                //   On desktop, this requires pressing "Return". Moving focus does not count.
                onAccepted: {
                    console.log("addressBar: 'accepted()' signal")
                    // Forward to the "Go" button to avoid duplicate code.
                    goButton.clicked()
                }
            }

            Button {
                id: goButton
                text: "Go"
                enabled: false
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    var searchTerm = database.normalize(addressBar.text)
                    // As in a web browser, we'll correct the "address" entered. Such as:
                    // " 2 165741  004149  " → "2165741004149"
                    addressBar.text = searchTerm
                    browserContent.text = contentOrMessage(searchTerm)
                }
            }

            Button {
                id: scanButton
                text: "Scan"
                Layout.alignment: Qt.AlignHCenter

                // Create the barcode scanner page and connect its signal to this page.
                //   Documentation for this technique: QtQuick.Controls.StackView::push()
                //   and "Dynamic QML Object Creation from JavaScript",
                //   https://doc.qt.io/qt-5/qtqml-javascript-dynamicobjectcreation.html and
                //
                //   By providing a component as URL and not an item, Kirigami takes care
                //   of dynamic object creation and deletion. Deletion makes sure the camera
                //   is stopped when the layer closes. This is simpler than creating a dynamic
                //   object ourselves, but also slower than just hiding the camera for later re-use.
                //   But as of Kirigami 2.10, there seems to be a bug preventing proper object
                //   destruction on page close when providing an item here instead of a component.
                //
                //   TODO: Once the Kirigami bug mentioned above is fixed, switch to providing an
                //   object that is not deleted (just hidden) when the page closes and keeps the
                //   camera in Camera.LoadedState. That should speed up showing the barcode scanner
                //   from the second time on. Not sure how much would be gained, though.
                onClicked: {
                    var scannerPage = pageStack.layers.push(Qt.resolvedUrl("ScannerPage.qml"));
                    scannerPage.barcodeFound.connect(onBarcodeFound)
                }
            }

            // TODO: Maybe add a "Bookmarks" button here.
        }

        Text {
            id: browserContent

            text: ''

            textFormat: Text.RichText // Otherwise we get Text.StyledText, offering much fewer options.
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            onLinkActivated: Qt.openUrlExternally(link)

            // Show a hand cursor when mousing over hyperlinks.
            //   Source: "Creating working hyperlinks in Qt Quick Text", https://blog.shantanu.io/?p=135
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton // Don't eat clicks on the Text.
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }
    }
}
