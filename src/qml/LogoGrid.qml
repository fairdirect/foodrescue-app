import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2

// A footer graphic crediting supporters; shown while no other browser content is present.
ColumnLayout {
    property alias redrawTimer: creditsRedrawTimer

    Image {
        id: logos

        // Initial aspect ratio as derived from the source image.
        property real sourceAspectRatio

        // Define the horizontal canvas size.
        Layout.fillWidth: true

        // Define the image height (not canvas height!).
        //   We cannot set this to the canvas height (parent.height), or equivalently use Layout.fillHeight
        //   as then vertical alignment in Layout.alignment would not work anymore. For alignment, a
        //   cell height has to be smaller than the space it can be positioned in (here the canvas).
        //   The max. image height is proportional to max. image width (= canvas width). The image
        //   height is lower than that maximum if limited by the canvas height.
        Layout.preferredHeight: Math.min(width * 1/sourceAspectRatio, parent.height)
        Layout.alignment: Qt.AlignBottom

        // TODO: i18n this, by using attributions-en.svg when the app language is German.
        source: "qrc:///images/credits-test-en.svg"
        fillMode: Image.PreserveAspectFit
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
            logos.sourceSize = (sizeByWidth.width < sizeByHeight.width) ? sizeByWidth : sizeByHeight

            // console.log("LogoGrid.qml: new sourceSize: " + logos.sourceSize.width + "x" + logos.sourceSize.height)
        }

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
        //   LXQt). But if it is a thread issue however, it could be solved here.
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
                var sizeByWidth = Qt.size(logos.width, logos.width * 1/logos.sourceAspectRatio)
                var sizeByHeight = Qt.size(logos.height * logos.sourceAspectRatio, logos.height)
                logos.sourceSize = (sizeByWidth.width < sizeByHeight.width) ? sizeByWidth : sizeByHeight

                // console.log("LogoGrid.qml: new sourceSize: " + logos.sourceSize.width + "x" + logos.sourceSize.height)
            }
        }
    }
}
