import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami
import local 1.0 as Local // Our custom QML components, as exported in main.cpp.


Item {
    id: autocomplete

    // Always give a QML component a defined height.
    //   The height is 0 by default, *not* the height of childrens. When not defining one here,
    //   the autocomplete will overlap other widgets following it in a ColumnLayout because it has
    //   height 0 and shows overflow. Defining height in the two ways below allows client code to
    //   place the widget into a Layout or a non-widget object. See: https://stackoverflow.com/a/38511223
    Layout.preferredHeight: addressBar.height
    height: addressBar.height

    // Place the auto-completions in a different layer on top of widgets following the autocomplete.
    //   When the auto-suggest box is shown, it will overlap the widgets following it, and due
    //   to the z index is shown on top. z indexes only work between sibling items, so
    //   we can't set this on suggestionsBox directly.
    z: 1

    property alias text: addressBar.text
    property alias completionsVisible: suggestionsBox.visible

    // Data source of autocomplete suggestions. Must be an array of strings.
    //   This is a string array, so access it with [index], not the usual .get(index).
    //
    //   TODO: Replace this with a QML ListModel model. This is supported by suggestionsList.model,
    //   which is a Repeater model (see https://doc.qt.io/qt-5/qml-qtquick-repeater.html#model-prop ).
    //   It allows to call clear() and to modify the model from code here in AutoComplete, which is
    //   not possible with a string list model. That will allow to remove the AutoComplete methods
    //   to do that which have to be overwritten by client code.
    property alias model: suggestionsList.model

    // The currently active, in-use address of the address bar.
    //   It differs from the address bar's text content while navigating through autocompletions.
    //   Then, the address as typed by the user is the address and the address bar content is
    //   a potential next address, with completion highlighting done based on the address.
    //
    //   TODO: Rename to something more generic now that this is ought to be a generic auto-complete widget.
    //
    //   TODO: Make code in here less redundant by setting autocomplete.text in onAddressChanged instead
    //   of imperatively in multiple locations.
    property string address

    // This signal is emitted when the Return or Enter key is pressed in the autocomplete's underlying
    // text field, or a completion is accepted with a mouse click or by pressing Return or Enter when
    // it is selected.
    signal accepted()

    // Normalize user input to a form based on which the completions can be calculated. Only a do-nothing
    // implementation is provided. Client code should overwrite this as required by the model used.
    function normalize(input) { return input }


    // Highlight the completed parts of a multi-substring search term in bold, using HTML "<b>".
    // Considered private.
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


    RowLayout {
        // Our parent "Item {}" is not a layout, so we can't use the attached Layout properties.
        // anchors.fill: parent
        anchors.left: parent.left
        anchors.right: parent.right

        // A text field with Google-like auto-completion.
        //   TODO: Set a minimum width. Otherwise, without AutoComplete { Layout.fillWidth: true },
        //   the auto-complete box would not be visible at all.
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

            focus: true
            placeholderText: "barcode number, or food name (plural form only)"
            Layout.fillWidth: true

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
                autocomplete.address = text

                // TODO: This should better be set as a binding on goButton itself.
                goButton.enabled = autocomplete.address == "" ? false : true;

                // Don't auto-complete nothing or barcode numbers.
                if (autocomplete.address == "" || autocomplete.address.match("^[0-9 ]+$"))
                    database.clearCompletions()
                // Auto-complete a category name fragment (or later other "address" type).
                //   Not done in onTextChanged because navigating through completion should not update them.
                else
                    database.updateCompletions(autocomplete.address, 10)

                // Invalidate the completion selection, because the user edited the address so
                // it does not correspond to any current completion. Also completions might have been cleared.
                //   TODO: Probably better implement this reactively via onModelChanged, if there is such a thing.
                suggestionsList.currentIndex = -1

                suggestionsBox.visible = suggestionsList.model.length > 0 ? true : false;
            }

            // Handle the "text accepted" event, which sets the address from the text.
            //   This event is also artificially emitted by the "Go" button and by clicking on
            //   an auto-suggest proposal.
            //
            //   This event is emitted by a TextField when the user finishes editing it.
            //   In desktop software, this requires pressing "Return". Moving focus does not count.
            onAccepted: {
                console.log("addressBar: 'accepted()' signal")
                autocomplete.completionsVisible = false

                // When clicking into addressBar again, the completions shown when executing the
                // search should appear again. So don't database.clearCompletions(). But selecting
                // them should start afresh, so:
                //   TODO: Probably better implement this reactively via onModelChanged, if there is such a thing.
                suggestionsList.currentIndex = -1

                // As in a web browser, we'll correct the "address" entered. Such as:
                // " 2 165741  004149  " → "2165741004149"
                var searchTerm = normalize(text)
                autocomplete.text = searchTerm
                autocomplete.address = searchTerm

                // Send the accepted() signal of the parent component so client code can react.
                autocomplete.accepted()
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
                        event.accepted = true;
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
                        event.accepted = true;
                        break

                    case Qt.Key_Down:
                        suggestionsList.currentIndex++

                        // When moving past the last item, cycle through completions from the start again.
                        if (suggestionsList.currentIndex > suggestionsList.model.length - 1)
                            suggestionsList.currentIndex = 0

                        addressBar.text = suggestionsList.model[suggestionsList.currentIndex]
                        event.accepted = true;
                        break

                    case Qt.Key_Return:
                        addressBar.accepted()
                        event.accepted = true;
                        break
                    }
                }
                else {
                    switch (event.key) {

                    // This way, "double Escape" can be used to move the focus to the browser.
                    // The first hides the suggestions box, the second moves the focus.
                    case Qt.Key_Escape:
                        // TODO: Do this in a different way, since "browser" is no longer accessible
                        //   after outsourcing this component to AutoComplete.qml.
                        browser.focus = true
                        event.accepted = true;
                        break

                    case Qt.Key_Down:
                        suggestionsBox.visible = suggestionsList.model.length > 0 ? true : false
                        console.log("After Key Down: suggestionsBox.visible = " + suggestionsBox.visible)
                        event.accepted = true;
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

                        // The repeater's delegate to represent one list item.
                        delegate: Kirigami.BasicListItem {
                            id: listItem

                            label: boldenCompletion(modelData, autocomplete.address)
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
}
