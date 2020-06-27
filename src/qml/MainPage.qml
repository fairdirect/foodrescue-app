import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami
import local 1.0 as Local // Our custom QML components, as exported in main.cpp.

// Page shown at startup of the application.
//   Shows the main area of the application, which contains every control element except the
//   sidebar drawer and any layers / sheets / drawers added on top.
Kirigami.ScrollablePage {
    id: mainPage

    // Page title.
    // TODO: Set the title as suitable for current window contents.
    title: "Food Rescue"

    Layout.fillWidth: true
    keyboardNavigationEnabled: true
    horizontalScrollBarPolicy: ScrollBar.AlwaysOff

    // Event handler for a dynamically created ScannerPage object.
    function onBarcodeFound(code) {
        console.log("mainPage: 'barcodeFound()' signal, code = " + code)
        addressBar.text = code
        browserContent.text = database.search(code)
    }

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

                // When the user finishes editing the text field.
                //   (On desktop, this requires pressing "Return". Moving focus does not count.)
                onAccepted: browserContent.text = database.search(addressBar.text)
            }

            Button {
                id: goButton
                text: "Go"
                enabled: false
                Layout.alignment: Qt.AlignHCenter
                onClicked: browserContent.text = database.search(addressBar.text)
            }

            Button {
                id: scannerButton
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

            text: '
                <html>

                  <h3>Lorem Ipsum 1</h3>

                  <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer et ligula
                    lectus. Praesent in ultrices ligula, quis luctus lorem. Mauris non magna
                    dignissim, euismod risus et, aliquet dolor. Curabitur suscipit elit ante, in
                    consequat ante tincidunt et. Nulla in pharetra felis. Sed sem neque, cursus
                    finibus odio pretium, ornare efficitur ipsum. Nullam vel dui leo. In sit amet
                    magna nibh. Vestibulum ultricies tincidunt diam, quis ullamcorper est. Donec
                    tristique tellus at felis mattis luctus. Praesent rhoncus ipsum sed lorem
                    fermentum cursus. Ut ut mollis ipsum.</p>

                  <h3>Lorem Ipsum 2</h3>

                  <p>Cras non nulla venenatis sem tempor pulvinar. Integer sed accumsan orci, id
                    dapibus ante. Duis finibus vitae tellus sed hendrerit. Suspendisse potenti.
                    Fusce sed leo egestas, venenatis eros non, lobortis libero. Nulla eu justo at
                    ante fringilla viverra eget sit amet nunc. Aliquam sed augue sed libero lacinia
                    lacinia sed non quam. Nunc ultrices ipsum nec eleifend fermentum. Ut viverra
                    suscipit bibendum. Duis quis neque pellentesque, volutpat ante quis, posuere
                    leo.</p>

                  <h3>Lorem Ipsum 2</h3>

                  <p>Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere
                    cubilia curae; Proin id justo sapien. Nam id nulla accumsan, rhoncus lacus id,
                    imperdiet erat. Ut dictum euismod purus, sit amet faucibus mi. Sed lacinia
                    dolor metus, aliquam cursus augue commodo sit amet. Aenean sed malesuada
                    tellus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur
                    ridiculus mus. In in fringilla dui, vel tempus justo.</p>

                </html>'

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
