import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami
import local 1.0 as Local // Our custom C++ based QML components, as exported in main.cpp.

// Page shown at startup of the application.
//   Shows the main area of the application, which contains every control element except the
//   sidebar drawer and any layers / sheets / drawers added on top.
Kirigami.ScrollablePage {
    id: browserPage

    title: "My Food Rescue"
    horizontalScrollBarPolicy: ScrollBar.AlwaysOff
    supportsRefreshing: false

    // Use a white browser background for everything, because the BMBF logo shown at startup must
    // be placed on white. Also it's ok for a content reader application to have a paper-like background.
    background: Rectangle { color: "white" }

    // Define the page toolbar's contents.
    //   A toolbar can have left / main / right / context buttons. The read-only property
    //   org::kde::kirigami::Page::globalToolBarItem refers to this toolbar.
    leftAction: Kirigami.Action {
        iconName: "go-previous"
        text: qsTr("Previous search")
        enabled: browserHistory.backPossible
        onTriggered: {
            // showPassiveNotification("History back")
            displayContent(browserHistory.back(), false)
        }
    }

    mainAction: Kirigami.Action {
        // TODO: Replace this with a custom icon because this is not part of the FreeDesktop
        // icon naming specs (see https://specifications.freedesktop.org/icon-naming-spec/icon-naming-spec-latest.html#names ).
        // So other themes than Breeze that the user might use might not have it. However, using
        // a custom icon in Kirigami Page actions is currently prevented by a bug.
        iconName: "view-barcode"
        text: qsTr("Scan")

        // Create the barcode scanner page and connect its signal to this page.
        //   Documentation for this technique: QtQuick.Controls.StackView::push()
        //   and "Dynamic QML Object Creation from JavaScript" at
        //   https://doc.qt.io/qt-5/qtqml-javascript-dynamicobjectcreation.html .
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
        onTriggered: {
            // On mobile platforms (and only there), Kirigami restores the keyboard focus after the
            // scanner page closes again, to keep the status of the on-screen keyboard. Not intended
            // because then the keyboard overlays the search results. So we give up that focus now
            // to prevent it from being restored later.
            autocomplete.focus = false

            var scannerPage = pageStack.layers.push(Qt.resolvedUrl("ScannerPage.qml"))
            scannerPage.barcodeFound.connect(displayContent)
        }
    }

    rightAction: Kirigami.Action {
        iconName: "go-next"
        text: qsTr("Next search")
        enabled: browserHistory.forwardPossible
        onTriggered: {
            // showPassiveNotification("History forward")
            displayContent(browserHistory.forward(), false)
        }
    }

    // No contextual actions so far.
    contextualActions: []

    onWidthChanged: {
        // Configure the timer so it fires with a delay after the last resize.
        splashContent.redrawTimer.running ? splashContent.redrawTimer.restart() : splashContent.redrawTimer.start()
        // console.log("BrowserPage.qml: browserPage: widthChanged() received")
    }

    onHeightChanged: {
        // Configure the timer so it fires with a delay after the last resize.
        splashContent.redrawTimer.running ? splashContent.redrawTimer.restart() : splashContent.redrawTimer.start()
        // console.log("BrowserPage.qml: browserPage: heightChanged() received")
    }

    // Utility function to display content for a certain search string in the browser.
    // @param searchTerm string  The barcode or category name to display the content for.
    // @param addToHistory boolean  If this call to display content should be appended as a new item
    //   to the browser's history. Set to `false` while navigating through the past of that history.
    function displayContent(searchTerm, addToHistory = true) {
        console.log("BrowserPage: 'displayContent()' called, searchTerm = " + searchTerm)
        if (addToHistory)
            browserHistory.add(searchTerm)

        autocomplete.input = searchTerm

        // TODO: Set browserPage.title as a property binding, not imperatively like below.
        browserPage.title = searchTerm === "" ? "My Food Rescue" : searchTerm

        var uiLanguage = Qt.locale().name.substring(0,2)
        var content = database.content(searchTerm, uiLanguage)
        browserContent.text = contentOrMessage(content, searchTerm)

        // If nothing was found, the user wants to search again instead of scroll. So we take the
        // focus back, which was givev up in the AutoComplete onAccepted event handler.
        if (content === "") {
            autocomplete.focus = true;
            autocomplete.completionsVisible = false;
        }
    }

    // Displays a database search result or a "nothing found" message, as appropriate.
    // @param rawContent string  A raw database search result.
    // @param searchTerm string  The search term that lead to finding rawContent. Optional.
    // TODO: i18n the messages properly.
    function contentOrMessage(rawContent, searchTerm = "") {
        if (rawContent === "")
            if (searchTerm === "")
                return qsTr("No content found.")
            else
                return qsTr("No content found for") + " \"" + searchTerm + "\"."
        else
            return rawContent
    }

    // Clean up a search string a user entered into the browser's "address bar".
    function normalize(searchString) {
        return database.normalize(searchString)
    }

    // Interface to the food rescue content.
    //   This is a C++ defined QML type, see ContentDatabase.h. Interface: method content(string).
    //   Note that this is is a different ContentDatabase object from that created in main.cpp. It still
    //   works because we rely on the QSqlDatabase default connection; see ContentDatabase.cpp for
    //   details.
    Local.ContentDatabase {
        id: database
    }

    // Scrollable element wrapping the content.
    //   This is necessary to allow scrolling with the keyboard in a Kirigami ScrollablePage.
    //   Details: https://stackoverflow.com/a/62853851
    //
    //   Positioning, sizing and margin'ing the Flickable with either Layout or anchors properties
    //   does not work, probably because ScrollablePage overrides these settings of a Flickable
    //   when integrating it into the page. Kirigami behaves differently (and correctly) if we would
    //   only place the Flickable's content elements here in place of the Flickable. So the inability
    //   to position, size and margin a Flickable here should be considered a bug in Kirigami.
    //   For now, we can only size the Flickable to be large enough for its content (browserUI).
    //
    //   TODO: Get the above mentioned bug in Kirigami fixed, then set the sizing and margins.
    Flickable {
        id: browser

        focus: !autocomplete.focus
        contentWidth: browserUI.width
        contentHeight: browserUI.height

        // TODO: These margins probably have no effect yet due to the Kirigami bug documented for
        // the Flickable above. Test and confirm.
        bottomMargin: 20
        leftMargin:   20
        rightMargin:  20
        topMargin:    20

        Keys.onPressed: {
            switch (event.key) {

            // Scrolling in the browser page with the keyboard.

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

            // For editing the autocomplete text field.
            //   Note that F2 is a typical shortcut for "go to edit mode".
            case Qt.Key_F2:
                autocomplete.focus = true;
                if (database.completionModel.length > 0)
                    autocomplete.completionsVisible = true;
                event.accepted = true;
                break
            }
        }

        Column {
            id: browserUI

            // Hack to make the margins of "browser" effective, which do not yet have an effect of
            // their own due to a Kirigami bug documented above at "Flickable { … }"
            width: browserPage.width - browser.leftMargin - browser.rightMargin
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
                    placeholderText: qsTr("food category or barcode")

                    onInputChanged: {
                        console.log("BrowserPage: autocomplete: 'inputChanged()' signal received")

                        // Don't auto-complete nothing or barcode numbers.
                        if (input == "" || input.match("^[0-9 ]+$"))
                            database.clearCompletions()
                        // Auto-complete a category name fragment.
                        else {
                            // Can't be made into a custom property "uiLanguage" since Qt.locale()
                            // does not have a change notification signal connected to it.
                            //   TODO: Make QML receive a custom signal for language and locale changes,
                            //   and use that to update a custom property "uiLanguage". Instructions:
                            //   Create a QEvent::LanguageChange event handler using the technique
                            //   shown in https://forum.qt.io/post/276252 . Make it emit a signal that
                            //   QML components can then react to. The signal can be the same that was
                            //   previously present in the translating-qml demo application, see
                            //   https://github.com/retifrav/translating-qml/blob/1a97871/trans.h#L25
                            var uiLanguage = Qt.locale().name.substring(0,2)
                            database.updateCompletions(input, uiLanguage, 10)
                        }
                    }

                    onAccepted: displayContent(input)

                    // Clean up a search string a user entered into the browser's "address bar".
                    //   TODO: Somehow merge this with the function normalize() at the top of thils file.
                    //   There has to be a function in autocomplete to overwrite its internal
                    //   implementation. But also there has to be a function higher up in the
                    //   nesting structure of this page because it is called in searchButton#onClicked.
                    function normalize(searchString) {
                        return database.normalize(searchString)
                    }
                }

                ToolButton {
                    id: searchButton
                    icon.name: "system-search" // Other good options: checkmark, key-enter
                    visible: !Kirigami.Settings.isMobile
                    enabled: autocomplete.input === "" ? false : true;
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        console.log("BrowserPage: searchButton: 'clicked()' received")

                        // Prepare the search just as in the onAccepted event handler of the
                        // autocomplete text field itself.
                        var searchTerm = normalize(autocomplete.text)
                        autocomplete.input = searchTerm

                        // Forward to the autocomplete widget to avoid duplicating code.
                        //   The autocomplete is the right element to handle its own input. This button
                        //   is just an independent element providing a convenience action.
                        //
                        //   TODO: This is necessary somehow, but probably also is the cause for
                        //   rendering the page twice, as this event will somehow call itself. To be fixed.
                        autocomplete.accepted()
                    }
                }

                // TODO: Maybe add an "Add Bookmark" button here, with a star icon.
            }

            Text {
                id: browserContent

                anchors.left: parent.left
                anchors.right: parent.right

                text: ""
                textFormat: Text.RichText // Otherwise we get Text.StyledText, which is much less sophisticated.
                wrapMode: Text.Wrap
                onLinkActivated: Qt.openUrlExternally(link)

                MouseArea {
                    anchors.fill: parent

                    // Show a hand cursor when mousing over hyperlinks.
                    //   Source: "Creating working hyperlinks in Qt Quick Text", https://blog.shantanu.io/?p=135
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor

                    // Don't eat clicks but forward them to the Text parent element. Otherwise links won't work.
                    acceptedButtons: Qt.NoButton

                    // Let clicking on browser content de-focus the autocomplete widget.
                    onClicked: autocomplete.focus = false
                    // TODO: Check if consuming left-click events interferes with activating hyperlinks
                    // via parent.onLinActivated. Before adding the focus change behavior on click the
                    // MouseArea had "acceptedButtons: Qt.NoButton" to not eat click events. We might now
                    // have to forward the mouse event to the parent.
                }
            }

            // Component to fill the empty space at the bottom of the page so that clicking there will
            // remove the focus from the autocomplete field. Also contains startup screen images.
            //
            //   Placing this into the Kirigami.ScrollablePage itself would be much simpler in terms of
            //   anchors. But it is not possible because of ScrollablePage re-parents its content elements,
            //   so that elements appearing as sibling elements in ScrollablePage in the code are no longer
            //   sibling elements at runtime. This leads to an error "Cannot anchor to an item that isn't a
            //   parent or sibling." So instead we have to do a calculation to size this element so that it
            //   pushes the size of its ancestor element "browser" (the Flickable) to be as high as the
            //   page.
            //
            //   This is a Rectangle only to support debugging by outlining the area. Otherwise, it could also be
            //   replaced with a MouseArea, then rendering the nested MouseArea inside unnecessary.
            //
            //   TODO: Replace this with MouseArea { anchors.fill: parent; z: -1; onClicked: autocomplete.focus = false; }
            //   as a preceding sibling of Flickable. This has the advantage to fill the whole page, incl.
            //   the Flickable's borders on which one cannot click right now. However, this is not possible
            //   right now due to a Qt bug that makes any TextField unresponsive to clicks when underlaid or
            //   overlaid with a MouseArea. It seems to be this issue: https://forum.qt.io/topic/64041 . So,
            //   report this bug, get it fixed, then simplify the implementation accordingly.
            //
            //   TODO: Other alternative implementations are presented in https://stackoverflow.com/a/55101935 .
            //   So far we could not get any of them to work in a Kirigami.ScrollablePage, but we can try again.
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right

                color: "transparent" // To debug the element's sizing, set this to "grey" instead of "transparent".
                height: {
                    var kirigamiHeaderHeight = 40 // TODO: Determine the exact value.
                    var flickableVerticalBorder = 20 // TODO: Determine this value dynamically.
                    var columnItemSpacing = 20 // TODO: Determine this value dynamically.
                    var heightToFill = browserPage.height - kirigamiHeaderHeight - flickableVerticalBorder
                        - headerBar.height - columnItemSpacing - browserContent.height - flickableVerticalBorder

                    return (heightToFill > 0) ? heightToFill : 0
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: autocomplete.focus = false
                }

                // Graphical content for the home screen at startup, before any user action.
                SplashContent {
                    id: splashContent

                    anchors.fill: parent
                    windowWidth: browserPage.width
                    windowHeight: browserPage.height

                    // Hide permanently after the first search (as the browser always has content after that,
                    // and if only "No content found.").
                    //   TODO: Better destroy the instance, or remove the image source, as it probably eats
                    //   CPU time and memory even while invisible.
                    visible: browserContent.text == ""

                    // The app logo, shown large and centrally on the home screen.
                    topImage: "qrc:///images/applogo-2_minified.svg"
                    topImageAlignment: Image.AlignHCenter

                    // A footer graphic crediting supporters.
                    //   This is shown in a localized version. If no localized version is available,
                    //   the English version is shown.
                    //
                    //   TODO: Make this work as a dynamic binding to adapt when the locale changes.
                    //   This binding depends on Qt.locale() but does not react when the locale
                    //   changes due to a limitation of Qt (the QEvent::LocaleChanged signal is
                    //   not automatically forwarded to the Qt object).
                    bottomImage: {
                        var lang = Qt.locale().name.substring(0,2)
                        if (lang === "de" || lang === "en")
                            return "qrc:///images/credits-" + lang + "-3_minified.svg"
                        else
                            return "qrc:///images/credits-en-3_minified.svg"
                    }
                    bottomImageAlignment: Qt.AlignLeft // Because the BMBF logo must be left-aligned.
                }
            }
        }
    }
}
