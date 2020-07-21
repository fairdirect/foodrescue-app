import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami


// A scalable but size-limited graphical notice to display information using an SVG image.
//   Typical uses include showing credits by rendering supporter logos to the homescreen. The
//   implementation provides memory-efficient scaling, as the SVG will always be drawn with only the
//   pixels needed. You could also use a raster graphic image instead of a SVG here, but that will
//   not be memory efficient as you'd size it for the largest screens the application will be used on.
ColumnLayout {
    // TODO: Documentation.
    property alias imageSource: image.source

    // TODO: Documentation.
    property alias redrawTimer: creditsRedrawTimer

    // Information about the (otherwise inaccessible) width of the containing window, to be set by the
    // parent object when instantiating a LogoGrid.
    property int windowWidth
    property int windowHeight

    // We want to control sizes accuractely by ourselves, and avoiding automatic spacing makes that easier.
    spacing: 0

    // Mechanism to adapt the image size and storage requirements to the window size.
    //   An image created from a SVG file is rendered once and scaled as a raster
    //   image when changing its size. When scaling up, this leads to pixelation /
    //   aliasing artefacts. When scaling down, this leads to unnecessary memory
    //   usage because the original rendered size is still kept in memory. We solve
    //   both issues by re-rendering the SVG into the available space. Since
    //   re-drawing a SVG image is slow, we don't want to do it for each resize event,
    //   so instead we run a timer to trigger it only if no resize events have been
    //   received for a certain time (see the onWidthChanged / onHeightChanged handlers above).
    //
    //   TODO: Fix that window repainting will occasionally stop while holding the
    //   window resize handle and until releasing it. This did not happen before
    //   introducing the timer. It could be a window manager issue (Linux platform,
    //   LXQt). But if it is a thread issue however, it could be solved here. Perhaps asynchronous
    //   rendering will help: https://doc.qt.io/qt-5/qml-qtquick-image.html#asynchronous-prop
    Timer {
        id: creditsRedrawTimer
        interval: 100
        onTriggered: {
            // TODO: Do not change the source size if the new values are the same, to avoid a redraw.
            // TODO: Do not set the source size smaller than a certain reasonable limit. That way,
            // no extreme pixelation will occur even when scaling up a very small window.
            // TODO: Do not allow to set both sourceSize dimensions to 0 as that will use the
            // sourceSize dimensions from the SVG file instead (which can be huge).

            // See above for explanations on the same calculation.
            var sizeByWidth = Qt.size(image.width, image.width * 1/image.sourceAspectRatio)
            var sizeByHeight = Qt.size(image.height * image.sourceAspectRatio, image.height)
            image.sourceSize = (sizeByWidth.width < sizeByHeight.width) ? sizeByWidth : sizeByHeight

            // console.log("LogoGrid.qml: new sourceSize: " + logos.sourceSize.width + "x" + logos.sourceSize.height)
        }
    }

    Image {
        id: image

        // Initial aspect ratio as derived from the source image.
        property real sourceAspectRatio

        // Define the horizontal canvas size.
        Layout.fillWidth: true

        // Limit logo size on large screens to be visually a footer element.
        //   We limit the desktop screen logo bounding box to 60%x25% of the window, to. But also
        //   show it at least in 540x216 px to be readable. When the parent element is smaller than
        //   that, the logos will be scaled to fit into it, and may then be unreadable (but that's ok).
        //   -1 keeps the property at its default value on mobile devices.
        //
        //   TODO: On large tablet devices, limit logo size similarly.
        //   TODO: Ideally, define the minium size in mm instead of 540x216 px.
        //   TODO: Expose the window percentages and static size as properties of ImageNote.
        Layout.maximumWidth: (Kirigami.Settings.isMobile) ? -1 : Math.max(windowWidth * 0.6, 540)
        Layout.maximumHeight: (Kirigami.Settings.isMobile) ? -1 : Math.max(windowHeight * 0.25, 216)

        // Define the image height (not canvas height!).
        //   We cannot set this to the canvas height (parent.height), or equivalently use Layout.fillHeight
        //   as then vertical alignment in Layout.alignment would not work anymore. For alignment, a
        //   cell height has to be smaller than the space it can be positioned in (here the canvas).
        //   The max. image height is proportional to max. image width (= canvas width). The image
        //   height is lower than that maximum if limited by the canvas height.
        Layout.preferredHeight: Math.min(width * 1/sourceAspectRatio, parent.height)
        Layout.alignment: Qt.AlignBottom

        fillMode: Image.PreserveAspectFit
        horizontalAlignment: Image.AlignLeft // Because the BMBF logo always have to be left-aligned.
        mipmap: true // Renders SVGs less blurry, esp. vertical and horizontal lines.

        Component.onCompleted: {
            // implicitWidth and implicitHeight are set by the system based on the source size and
            // all configured scaling, fitting and cropping operations.
            sourceAspectRatio = implicitWidth / implicitHeight

            // Set the initial sourceSize according to the initial display size, to not hold excess data.
            //   Calculation: There are always two ways to scale something relative to a target
            //   rectangle: so that the widths are the same, or so that the heights are the same.
            //   The smaller sized result is "scaled to fit" and the other "scaled to cover"/ But
            //   which is which depends on the aspect ratios of both the scaled content and the
            //   target rectangle, so to get the "scale to cover" size it is easiest to calculate
            //   both and select the smaller one.
            //
            //   Here, the "target rectangle" is the canvas available for drawing, namely "width"
            //   as set by "Layout.fillWidth" and "height" as set by "Layout.preferredHeight" plus
            //   any empty space around the cell, so here the full height of the surrounding
            //   ColumnLayout. (Indeed Qt does not set "height" to "Layout.preferredHeight"!)
            //
            //   Placed here and not as a sourceSize property binding because we want to provide an
            //   initial value only and redraw only occasionally using the timer mechanism below.
            var sizeByWidth = Qt.size(width, width * 1/sourceAspectRatio)
            var sizeByHeight = Qt.size(height * sourceAspectRatio, height)
            image.sourceSize = (sizeByWidth.width < sizeByHeight.width) ? sizeByWidth : sizeByHeight

            // console.log("LogoGrid.qml: new sourceSize: " + logos.sourceSize.width + "x" + logos.sourceSize.height)
        }
    }

    // Placeholder to guarantee the BMBF logo's minimum exclusion area in the mobile version.
    //   The BMBF logo is displayed immediately above and the logo SVG file has the exclusion area
    //   inside. However, in the mobile interface of Kirigami applications, the left / main / right
    //   action buttons are displayed at the bottom, and would overlay that exclusion area. With this
    //   placeholder, they only overlay it, and not the logo image.
    //
    //   At some starts of the Android aplplication, the Kirigami buttons will not overlay the
    //   placeholder but will be positioned immediately below. This seems to do with the event
    //   sequence at startup and is a race condition that we don't want to investigate. Too much
    //   space at the bottom is also not an issue, so we "play it safe".
    //
    //   This element can also be rendered in another color to help debug page sizing.
    Rectangle {
        color: "transparent"
        Layout.fillWidth: true
        Layout.preferredHeight: 20
        visible: Kirigami.Settings.isMobile
    }
}
