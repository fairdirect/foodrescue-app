import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami
import local 1.0 as Local // Our custom C++ based QML components, as exported in main.cpp.

// Page shown at startup of the application.
//   Shows the main area of the application, which contains every control element except the
//   sidebar drawer and any layers / sheets / drawers added on top.
//
//   TODO: Rename this component from MainPage to ContentBrowser.
Kirigami.ScrollablePage {
    id: mainPage

    // Page title.
    //   TODO: Set the title as suitable for the current contents displayed in this window.
    title: "Food Rescue"

    horizontalScrollBarPolicy: ScrollBar.AlwaysOff
    supportsRefreshing: false

    // Displays a database search result or a "nothing found" message, as appropriate.
    // @param rawContent string  A raw database search result.
    // @param searchTerm string  The search term that lead to finding rawContent. Optional.
    // TODO: i18n the messages properly.
    function contentOrMessage(rawContent, searchTerm = "") {
        if (rawContent === "")
            if (searchTerm === "")
                return "No content found."
            else
                return "No content found for \"" + searchTerm + "\"."
        else
            return rawContent
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

    // Scrollable element wrapping the content.
    //   This is necessary to allow scrolling with the keyboard in a Kirigami ScrollablePage.
    //   Details: https://stackoverflow.com/a/62853851
    //
    //   Positioning, sizing and margin'ing the Flickable with either Layout or anchors properties
    //   does not work, probably because ScrollablePage overrides these settings when integrating
    //   the element into the page. This is different from placing just the Flickable's content here
    //   and should be considered a bug in Kirigami. For now, just assume the Flickable takes up all
    //   available space up to its contentWidth × contentHeight.
    //
    //   TODO: Get the above mentioned bug in Kirigami fixed, then set the sizing and margins.
    Flickable {
        id: browser

        focus: !autocomplete.focus
        contentWidth: browserUI.width
        contentHeight: browserUI.height

        bottomMargin: 20
        leftMargin: 20
        rightMargin: 20
        topMargin: 20

        // Scrolling in the browser page with the keyboard.
        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_PageUp:
                flick(0, 2400)
                event.accepted = true;
                break

            case Qt.Key_PageDown:
                flick(0, -2400)
                event.accepted = true;
                break

            case Qt.Key_Up:
                flick(0, 800)
                event.accepted = true;
                break

            case Qt.Key_Down:
                flick(0, -800)
                event.accepted = true;
                break

            case Qt.Key_F2: // F2 is typically used for "edit mode", so it fits well here.
                autocomplete.focus = true;
                event.accepted = true;
                break
            }
        }

        Column {
            id: browserUI

            width: mainPage.width - browser.leftMargin - browser.rightMargin
            spacing: 20

            // Browser header toolbar: adress bar, "Go" button, "Scan" button.
            RowLayout {
                id: headerBar

                anchors.left: parent.left
                anchors.right: parent.right

                // Place the autocomplete suggestions box overlaying the content browser.
                //   z indexes only work between sibling items, so we can't implement this
                //   inside AutoComplete.
                z: 1

                AutoComplete {
                    id: autocomplete

                    model: database.completionModel
                    Layout.fillWidth: true
                    placeholderText: "barcode number or food name"

                    onInputChanged: {
                        console.log("MainPage: autocomplete: 'inputChanged()' signal received")

                        // Don't auto-complete nothing or barcode numbers.
                        if (input == "" || input.match("^[0-9 ]+$"))
                            database.clearCompletions()
                        // Auto-complete a category name fragment (and in the future other search term types).
                        else
                            database.updateCompletions(input, 10)
                    }

                    onAccepted: {
                        var content = database.content(input)
                        browserPage.text = contentOrMessage(content, input)

                        // AutoComplete gives up focus in its onAccepted handler. But if nothing was found
                        // the user wants to search again instead of scroll. So we take the focus back here.
                        if (content === "") {
                            focus = true
                            completionsVisible = false
                        }
                    }

                    function normalize(searchString) {
                        return database.normalize(searchString)
                    }
                }

                Button {
                    id: goButton
                    text: "Go"
                    enabled: autocomplete.input === "" ? false : true;
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        console.log("MainPage: goButton: 'clicked()' received")

                        // Forward to the autocomplete widget to avoid duplicating code.
                        //   The autocomplete is the right element to handle its own input. This button
                        //   is just an independent element providing a convenience action.
                        autocomplete.accepted()
                    }
                }

                Button {
                    id: scanButton
                    text: "Scan"
                    Layout.alignment: Qt.AlignHCenter

                    // Event handler for a dynamically created ScannerPage object.
                    // TODO: Document the parameters.
                    function onBarcodeFound(code) {
                        console.log("MainPage: scanButton: 'barcodeFound()' received, code = " + code)
                        autocomplete.input = code
                        var content = database.content(code)
                        browserPage.text = contentOrMessage(content, code)
                    }

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
                id: browserPage

                anchors.left: parent.left
                anchors.right: parent.right

                text: ""
                textFormat: Text.RichText // Otherwise we get Text.StyledText, offering much fewer options.
                wrapMode: Text.Wrap
                onLinkActivated: Qt.openUrlExternally(link)

                MouseArea {
                    anchors.fill: parent

                    // Show a hand cursor when mousing over hyperlinks.
                    //   Source: "Creating working hyperlinks in Qt Quick Text", https://blog.shantanu.io/?p=135
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor

                    // Let clicking on browser content de-focus the autocomplete widget.
                    onClicked: autocomplete.focus = false
                    // TODO: Check if consuming left-click events interferes with activating hyperlinks
                    // via parent.onLinActivated. Before adding the focus change behavior on click the
                    // MouseArea had "acceptedButtons: Qt.NoButton" to not eat click events. We might now
                    // have to forward the mouse event to the parent.
                }
            }

            // Component to fill the empty space of the page so that clicking there will remove the focus
            // from the autocomplete field.
            //
            //   The Rectangle is only here to allow outlining the area for debugging purposes. Otherwise,
            //   replacing it with a MouseArea will also do.
            //
            //   TODO: Replace this with MouseArea { anchors.fill: parent; onClicked: autocomplete.focus = false; }
            //   as a preceding sibling of Flickable. This has the advantage to fill the whole page, incl.
            //   the Flickable's borders on which one cannot click right now. However, this is not possible
            //   right now due to a Qt bug that makes any TextField unresponsive to clicks when underlaid or
            //   overlaid with a MouseArea. It seems to be this issue: https://forum.qt.io/topic/64041 . So,
            //   report this bug, get it fixed, then simplify the implementation as told above.
            //
            //   TODO: Other alternative implementations are presented in https://stackoverflow.com/a/55101935 .
            //   So far we could not get any of them to work in a Kirigami.ScrollablePage, but we can try again.
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                color: "transparent" // For debugging sizing, use "white".
                height: {
                    var kirigamiHeaderHeight = 40 // TODO: Determine the exact value.
                    var flickableVerticalBorder = 20 // TODO: Determine this value dynamically.
                    var columnItemSpacing = 20 // TODO: Determine this value dynamically.
                    var heightToFill = mainPage.height - kirigamiHeaderHeight - flickableVerticalBorder
                        - headerBar.height - columnItemSpacing - browserPage.height - flickableVerticalBorder

                    return (heightToFill > 0) ? heightToFill : 0
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: autocomplete.focus = false
                }
            }
        }
    }
}
