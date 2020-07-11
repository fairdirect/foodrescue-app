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
    // TODO: Document the parameters.
    function contentOrMessage(searchTerm) {
        var content = database.content(searchTerm)
        if (content === "")
            // TODO: i18n this message properly.
            return "No content found for \"" + searchTerm + "\"."
        else
            return content
    }


    // Event handler for a dynamically created ScannerPage object.
    // TODO: Document the parameters.
    function onBarcodeFound(code) {
        console.log("mainPage: 'barcodeFound()' signal, code = " + code)
        addressBar.text = code
        browserContent.text = contentOrMessage(code)
    }


    // Highlight the completed parts of a multi-substring search term in bold, using HTML "<b>".
    // @param fragmentsString  The part to not render in bold, when matched case-insensitively against the
    //   completion.
    // TODO: Document the parameters.
    // TODO: Make sure original contains no HTML tags by sanitizing these. Otherwise searching
    //   for parts of original below may match "word</b>" etc. and mess up the result.
    function boldenCompletion(completion, fragmentsString) {
        var fragments = fragmentsString.trim().split(" ")

        // Tracks the current processing position in "completion".
        //   This ensures that fragments are found in their given sequence. It also prevents
        //   modifying the <b> HTML tags themselves by matching against a "b" fragment. We'll simply
        //   work only on the part that has not yet had any insertions of HTML tags.
        var searchPos = 0

        // De-bold the sequential first occurrences of the fragments.
        for (var i = 0; i < fragments.length; i++) {
            var iCompletion = completion.toLowerCase() // "i" as in "case-Insensitive"
            var fragment = fragments[i]
            var fragmentStart = iCompletion.indexOf(fragment.toLowerCase(), searchPos)

            // Nothing to de-bolden if fragment was not found.
            //   TODO: This is an error condition that should generate a warning.
            if (fragmentStart === -1)
                continue

            var fragmentEnd = fragmentStart + fragment.length
            var completionBefore = completion.substr(0, fragmentStart)
            var completionDebold = completion.substr(fragmentStart, fragment.length)
            var completionAfter = completion.substr(fragmentEnd)

            completion = completionBefore + "</b>" + completionDebold + "<b>" + completionAfter

            // The search for the next fragment may start with completionAfter. That's after all HTML
            // tags inserted so far, which prevents messing them up when a "b" fragment matches against them.
            searchPos = completion.length - completionAfter.length - 1
        }

        // Wrap everything in bold to provide the proper "context" for the de-boldening above.
        //   This could not be done before to prevent matches of a "b" fragment against </b>".
        completion = "<b>" + completion + "</b>"

        return completion
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

            // Place the browser header bar on top of browserContent.
            //   When the auto-suggest box is shown, it will overlap the browser content, and due
            //   to the z index is shown on top. z indexes only work between sibling items, so
            //   we can't set this on suggestionsBox directly.
            z: 1

            // A text field with Google-like auto-completion.
            //   TODO: Refactor this into a reusable auto-suggest component.
            //
            //   TODO: Fix that the parts of this auto-complete widget have confusing internal
            //   dependencies. For example, after database.clearCompletions() one also always has to
            //   do suggestionsList.currentIndex = -1. Thats should be handled automatically.
            //
            //   TODO: Clear up the confusion between an invisible suggestion box and a visible one with
            //   no content. Both cases are used currently, but only one is necessary, as both look the same.
            //
            //   TODO: Use custom properties as a more declarative way to govern behavior here.
            //   For example, "completionsVisibility" set to an expression. See:
            //   https://github.com/dant3/qmlcompletionbox/blob/41eebf2b50ef4ade26c99946eaa36a7bfabafef5/SuggestionBox.qml#L36
            //   https://github.com/dant3/qmlcompletionbox/blob/master/SuggestionBox.qml
            //
            //   TODO: Use states to better describe the open and closed state of the completions box.
            //   See: https://code.qt.io/cgit/qt/qtdeclarative.git/tree/examples/quick/keyinteraction/focus/focus.qml?h=5.15#n166
            TextField {
                id: addressBar

                // The currently active, in-use address of the address bar.
                //   It differs from the address bar's text content while navigating through autocompletions.
                //   Then, the address as typed by the user is the address and the address bar content is
                //   a potential next address, with completion highlighting done based on the current address.
                property string address

                Layout.fillWidth: true
                focus: true
                placeholderText: "barcode number or category"

                // Disable predictive text input to make textEdited() signals work under Android.
                //   A workaround for multiple Qt bugs. See: https://stackoverflow.com/a/62526369
                inputMethodHints: Qt.ImhSensitiveData

                // Necessary to have a blinking cursor in addressBar at application startup.
                //   This is needed in addition to the same line in root.Component.onCompleted in BaseApp.qml.
                //   TODO: Simplify this stuff. Perhaps a FocusScope can help.
                Component.onCompleted: forceActiveFocus()

                // This event handler is undocumented for TextField and incompletely documented for TextInput,
                // which TextField wraps: https://doc.qt.io/qt-5/qml-qtquick-textinput.html#textEdited-signal .
                // However, it works, and is also proposed by code insight in Qt Creator.
                onTextEdited: {
                    // Whenever the user writes or deletes something (incl. by cut / paste), that
                    // defines the new current address of the address bar. When the address bar
                    // content changes otherwise, such as by navigating through completions, that's
                    // not the case. So we can't do this in "onTextChanged".
                    address = text

                    // TODO: This should better be set as a binding on goButton itself.
                    goButton.enabled = address == "" ? false : true;

                    // Don't auto-complete nothing or barcode numbers.
                    if (address == "" || address.match("^[0-9 ]+$"))
                        database.clearCompletions()
                    // Auto-complete a category name fragment (or later other "address" type).
                    //   Not done in onTextChanged because navigating through completion should not update them.
                    else
                        database.updateCompletions(address, 10)

                    // Invalidate the completion selection, because the user edited the address so
                    // it does not correspond to any current completion. Also completions might have been cleared.
                    //   TODO: Probably better implement this reactively via onModelChanged, if there is such a thing.
                    suggestionsList.currentIndex = -1

                    suggestionsBox.visible = suggestionsList.model.length > 0 ? true : false;
                }

                // Handle the "text accepted" event, which sets the address from the text.
                //   This event is emitted when the user finishes editing the text field.
                //   On desktop, this requires pressing "Return". Moving focus does not count.
                //   This event is also artificially emitted by the "Go" button and by clicking on
                //   an auto-suggest proposal.
                onAccepted: {
                    console.log("addressBar: 'accepted()' signal")
                    address = text
                    suggestionsBox.visible = false

                    // TODO: In the rest of this block, using address instead of text will be clearer.

                    // When clicking into addressBar again, the completions shown when executing the
                    // search should appear again. So don't database.clearCompletions(). But selecting
                    // them should start afresh, so:
                    //   TODO: Probably better implement this reactively via onModelChanged, if there is such a thing.
                    suggestionsList.currentIndex = -1

                    var searchTerm = database.normalize(addressBar.text)
                    // As in a web browser, we'll correct the "address" entered. Such as:
                    // " 2 165741  004149  " → "2165741004149"
                    addressBar.text = searchTerm
                    browserContent.text = contentOrMessage(searchTerm)

                    // To support arrow key and Page Up / Down scrolling, now the browser needs the focus.
                    browserContent.focus = true
                }

                onActiveFocusChanged: {
                    if (activeFocus && suggestionsList.model.length > 0)
                        suggestionsBox.visible = (text == "" || text.match("^[0-9 ]+$")) ? false : true
                        // TODO: Perhaps initialize the completions with suggestions based on the current
                        // text in addressBar. If the reason for not having the focus before was a previous
                        // search, then it has no completions at this point.
                    else
                        suggestionsBox.visible = false
                }

                // Process all keyboard events here centrally.
                //   Since the TextEdit plus suggestions box is one combined component, handling all
                //   key presses here is more tidy. They cannot all be handled in suggestionsBox as
                //   key presses are not delivered or forwarded to components in their invisible state.
                Keys.onPressed: {
                    console.log("addressBar: Keys.pressed(): " + event.key + " : " + event.text)

                    if (suggestionsBox.visible) {
                        switch (event.key) {

                        case Qt.Key_Escape:
                            suggestionsBox.visible = false
                            suggestionsList.currentIndex = -1
                            break

                        case Qt.Key_Up:
                            suggestionsList.currentIndex--

                            // When moving prior the first item, cycle through completions from the end again.
                            if (suggestionsList.currentIndex < 0)
                                suggestionsList.currentIndex = suggestionsList.model.length - 1

                            console.log(
                                "suggestionsList.model[" + suggestionsList.currentIndex + "]: " +
                                JSON.stringify(suggestionsList.model[suggestionsList.currentIndex])
                            )

                            addressBar.text = suggestionsList.model[suggestionsList.currentIndex]
                            break

                        case Qt.Key_Down:
                            suggestionsList.currentIndex++

                            // When moving past the last item, cycle through completions from the start again.
                            if (suggestionsList.currentIndex > suggestionsList.model.length - 1)
                                suggestionsList.currentIndex = 0

                            addressBar.text = suggestionsList.model[suggestionsList.currentIndex]
                            break

                        case Qt.Key_Return:
                            addressBar.accepted()
                            break
                        }
                    }
                    else {
                        switch (event.key) {

                        // This way, "double Escape" can be used to move the focus to the browser.
                        // The first hides the suggestions box, the second moves the focus.
                        case Qt.Key_Escape:
                            browserContent.focus = true
                            break

                        case Qt.Key_Down:
                            suggestionsBox.visible = suggestionsList.model.length > 0 ? true : false
                            console.log("After Key Down: suggestionsBox.visible = " + suggestionsBox.visible)
                            break
                        }
                    }
                }

                // Auto-suggest dropdown.
                //   Rectangle is only needed to provide a white background canvas for Repeater.
                Rectangle {
                    id: suggestionsBox

                    visible: false // Will be made visible once starting to type a category name.

                    anchors.top: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: childrenRect.height

                    color: "white" // The default, anyway.
                    border.width: 1
                    border.color: "silver" // TODO: Replace with the themed color used for field borders etc..

                    // Using Column { Repeater } instead of ListView because the latter does not support
                    // setting the height to the same as the content because it's meant to be scrollable.
                    // (And that includes trying "suggestionsBox.height: childrenRect.height".)
                    Column {
                        Repeater {
                            id: suggestionsList

                            // Repeater lacks ListView's currentIndex, so we'll add it.
                            property int currentIndex: -1 // No element highlighted initially.

                            // Data source of autocomplete suggestions.
                            //   This is a string array, so access with [index], not the usual .get(index).
                            model: database.completionModel

                            // The repeater's delegate to represent one list item.
                            delegate: Kirigami.BasicListItem {
                                id: listItem

                                label: boldenCompletion(modelData, addressBar.address)
                                width: suggestionsBox.width
                                reserveSpaceForIcon: false

                                // Remove any initial background coloring except on mouse-over.
                                highlighted: index == suggestionsList.currentIndex

                                onClicked: {
                                    suggestionsList.currentIndex = index

                                    console.log("modelData = " + JSON.stringify(modelData))

                                    addressBar.text = modelData
                                    addressBar.accepted()
                                }
                            }
                        }
                    }
                }

            }

            Button {
                id: goButton
                text: "Go"
                enabled: false
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    console.log("goButton: 'clicked()' signal")

                    // Forward to the address bar to avoid duplicating code.
                    //   The address bar is the right element to handle its own input. This button
                    //   is just an independent element triggering an action there for convenience.
                    addressBar.accepted()
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

            text: ""

            textFormat: Text.RichText // Otherwise we get Text.StyledText, offering much fewer options.
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            onLinkActivated: Qt.openUrlExternally(link)

            // Show a hand cursor when mousing over hyperlinks.
            //   Source: "Creating working hyperlinks in Qt Quick Text", https://blog.shantanu.io/?p=135
            MouseArea {
                anchors.fill: parent
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: browserContent.focus = true
                // TODO: Check if consuming left-click events interferes with activating hyperlinks
                // via parent.onLinActivated. Before adding the focus change behavior on click the
                // MouseArea had "acceptedButtons: Qt.NoButton" to not eat click events. We might now
                // have to forward the mouse event to the parent.
            }
        }
    }
}
