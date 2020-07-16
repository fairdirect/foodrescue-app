import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami
import local 1.0 as Local // Our custom QML components, as exported in main.cpp.

// Auto-complete widget with completion highlighting similar to a Google Search.
//
//   When using this, be sure to adjust the z indexes of sibling items so that the container of the
//   autocomplete widget (e.g. RowLayout) has a higher z value than the container of every widget
//   following it that might be overlaid by the suggestions.
//
//   TODO: To avoid having to adjust z indexes when using this, perhaps place the suggestions into
//   a Kirigami Sheet, or use the same mechanism to overlay a target widget. Or introduce a property
//   to reference the component to overlay, and then do Component.onCompleted: { while
//   (notOverlaid(targetToOverlay)) { ancestor = ancestor.parent; ancestor.z += 1000 }.
//
//   TODO: Set a minimum width. Otherwise, without AutoComplete { Layout.fillWidth: true },
//   the auto-complete box would not be visible at all.
//
//   TODO: Fix that the parts of this auto-complete widget have confusing internal
//   dependencies. For example, after changing the address property one also always has to
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
Item {
    id: autocomplete

    // Always give a QML component a defined height.
    //   The height is 0 by default, *not* the height of childrens. When not defining one here,
    //   the autocomplete will overlap other widgets following it in a ColumnLayout because it has
    //   height 0 and shows overflow. Defining height in the two ways below allows client code to
    //   place the widget into a Layout or a non-widget object. See: https://stackoverflow.com/a/38511223
    Layout.preferredHeight: addressBar.height
    height: addressBar.height

    // Data source containing the current autocomplete suggestions.
    //   In JavaScript, this is a string array, so access it with [index], not the usual .get(index).
    //   For implementing in C++, use QStringList.
    //
    //   TODO: Replace this with a QML ListModel model. This is supported by suggestionsList.model,
    //   which is a Repeater model (see https://doc.qt.io/qt-5/qml-qtquick-repeater.html#model-prop ).
    //   It allows to call clear() and to modify the model from code here in AutoComplete, which is
    //   not possible with a string list model. That will allow to remove the AutoComplete methods
    //   to do that which have to be overwritten by client code.
    //
    //   TODO: Even better, allow client code to set this to any type of model accepted by a Repeater.
    //   See: https://doc.qt.io/qt-5/qml-qtquick-repeater.html#model-prop
    property alias model: suggestionsList.model

    // The currently active, in-use address of the address bar.
    //   It differs from the address bar's text content while navigating through autocompletions.
    //   Then, the address as typed by the user is the address and the address bar content is
    //   a potential next address, with completion highlighting done based on the address.
    //
    //   Use the `onAddressChanged` handler to update the model providing the completions to the
    //   autocomplete. For example, if the model is the result of a database query, then the database
    //   query has to be run again to update it.
    //
    //   TODO: Rename to something more generic now that this is ought to be a generic auto-complete widget.
    //   Proposal: name it "input", as that relates to "what the user entered", which can be something
    //   different from "what is currently in the text field".
    //
    //   TODO: Make code in here less redundant by setting autocomplete.text in onAddressChanged instead
    //   of imperatively in multiple locations.
    property string address

    // The current textual content of the address bar.
    //   When the address (see property `address`) changes, the text changes. But when the text changes,
    //   the address changes only if this was triggered by user input.
    property alias text: addressBar.text
    property alias completionsVisible: suggestionsBox.visible

    // This signal is emitted when the Return or Enter key is pressed in the autocomplete's underlying
    // text field, or a completion is accepted with a mouse click or by pressing Return or Enter when
    // it is selected.
    signal accepted()

    // Normalize user input to a form based on which the completions can be calculated.
    //   Only a do-nothing implementation is provided. Client code should overwrite this as required
    //   by the model used.
    function normalize(input) { return input }

    // Highlight the auto-completed parts of a multi-substring search term using HTML.
    //   This implementation uses <b> tags to highlight the completed portions. Client code can
    //   overwrite this to implement a different type of completion.
    // @param fragmentsString  The part to not render in bold, when matched case-insensitively against the
    //   completion.
    // TODO: Document the parameters.
    // TODO: Make sure original contains no HTML tags by sanitizing these. Otherwise searching
    //   for parts of original below may match "word</b>" etc. and mess up the result.
    // TODO: Add a parameter to make it configurable which HTML tag (incl. attributes) to use for the
    //   highlighting.
    // TODO: Maybe add a parameter to de-highlight the original parts with configurable HTML.
    function highlightCompletion(completion, fragmentsString) {
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

    // React to our own auto-provided signal for a change in the "address" property.
    //   When client code also implements onAddressChanged when instantiating an AutoComplete, it
    //   will not overwrite this handler but add to it. So no caveats when reacting to own signals.
    onAddressChanged: {
        console.log("AutoComplete: autocomplete: 'addressChanged()' signal received")
        text = address
    }

    // The text field where a user enters to-be-completed text.
    TextField {
        id: addressBar

        focus: true
        placeholderText: "barcode number, or food name (plural form only)"

        // Our parent "Item {}" is not a layout, so we can't use "Layout.fillWidth: true".
        anchors.left: parent.left
        anchors.right: parent.right

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
            // Update the current address when the user changes the text.
            //   User changes include cutting and pasting. The "textChanged()" event however
            //   is emitted also when software changes the text field content (such as when
            //   navigating through completions), making it  the wrong place to update the address.
            //   This automatically emits addressChanged() so client code can adapt the model.
            autocomplete.address = text

            // TODO: This should better be set as a binding on goButton itself.
            goButton.enabled = autocomplete.address == "" ? false : true;

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
            console.log("AutoComplete: addressBar: 'accepted()' signal received")
            autocomplete.completionsVisible = false

            // When clicking into addressBar again, the completions shown when executing the
            // search should show again. But selecting them should start afresh.
            //   TODO: Probably better implement this reactively via onModelChanged, if there is such a thing.
            suggestionsList.currentIndex = -1

            // As in a web browser, we'll correct the "address" entered. Such as:
            // " 2 165741  004149  " → "2165741004149"
            var searchTerm = normalize(text)
            autocomplete.address = searchTerm

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
            console.log("AutoComplete: addressBar: Keys.pressed(): " + event.key + " : " + event.text)

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

                        label: highlightCompletion(modelData, autocomplete.address)
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
}
