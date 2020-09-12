import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami

// Two size-adjusting SVG images that can be used as splash page or start screen content.
//   Typical uses for the top image include a large logo or illustration similar to a splashscreen.
//
//   Typical uses for the bottom image include showing credits by using supporter logos. The
//   implementation provides memory-efficient scaling, as the SVG will always be drawn with only the
//   pixels needed, even after resizing the window. In contrast, rendering the SVG once or using a
//   raster graphic image is only perfectly memory efficient for one display size of the image,
//   measured in pixel.
//
//   Usage instructions: This component takes only the space you assign to it explicitly. So upon
//   instantiation, assign to it the maximum space it should fill. For example:
//   SplashContent { anchors.fill: parent }.
ColumnLayout {
    id: container

    // TODO: Documentation.
    property alias topImage: topImage.source

    // Horizontal position of the bottom image within its assigned space.
    //   Possible values: one of Qt.AlignLeft, Qt.AlignHCenter, Qt.AlignRight. When not specified, the default
    //   is Qt.AlignHCenter.
    property alias topImageAlignment: topImage.horizontalAlignment

    // TODO: Documentation.
    property alias bottomImage: bottomImage.source

    // Horizontal position of the bottom image within its assigned space.
    //   Possible values: one of Qt.AlignLeft, Qt.AlignHCenter, Qt.AlignRight. When not specified, the default
    //   is Qt.AlignHCenter.
    property alias bottomImageAlignment: bottomImage.horizontalAlignment

    // TODO: Documentation.
    property alias redrawTimer: timer

    // Information about the (otherwise inaccessible) width of the containing window, to be set by the
    // parent object when instantiating this QML type.
    property int windowWidth
    property int windowHeight

    // We want to control sizes accuractely by ourselves, and avoiding automatic spacing makes that easier.
    spacing: 0

    // Determine the image size needed to "scale to fit" to a given target rectangle.
    //   There are always two ways to scale something relative to a target rectangle: so that the
    //   widths are the same, or so that the heights are the same. The smaller of both is
    //   "scale to fit" and the larger "scale to cover".
    //   @param targetWidth integer  The width of the target rectangle to scale to.
    //   @param targetHeight integer  The height of the target rectangle to scale to.
    //   @aspectRatio integer  The aspect ratio of the image to scale as width/height.
    //   @return Qt.size  The size of the source image needed to fit into the target rectangle.
    function scaleToFitSize(targetWidth, targetHeight, aspectRatio) {
        // To calculate the "scale to fit" size, it is easiest to calculate both scaled sizes and
        // and select the smaller one. Because any of them can be the smaller one, depending on
        // the aspect ratios of both the source image and target rectangle.

        var sizeByWidth = Qt.size(targetWidth, targetWidth * 1/aspectRatio)
        var sizeByHeight = Qt.size(targetHeight * aspectRatio, targetHeight)

        return (sizeByWidth.width < sizeByHeight.width) ? sizeByWidth : sizeByHeight
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
    //   LXQt). But if it is a thread issue however, it could be solved here. Perhaps asynchronous
    //   rendering will help: https://doc.qt.io/qt-5/qml-qtquick-image.html#asynchronous-prop
    //
    //   TODO: Do not change the source sizes if the new values are the same, to avoid a redraw.
    //
    //   TODO: Do not set the source size smaller than a certain reasonable limit. That way,
    //   no extreme pixelation will occur even when scaling up a very small window.
    //
    //   TODO: Do not allow to set both sourceSize dimensions to 0 as that will use the
    //   sourceSize dimensions from the SVG file instead (which can be huge).
    Timer {
        id: timer
        interval: 100
        onTriggered: {
            topImage.sourceSize = scaleToFitSize(
                topImage.width, topImage.Layout.preferredHeight, topImage.sourceAspectRatio
            )
            bottomImage.sourceSize = scaleToFitSize(
                bottomImage.width, bottomImage.Layout.preferredHeight, bottomImage.sourceAspectRatio
            )
            // console.log("ImageNotice.qml: new sourceSize: " + logos.sourceSize.width + "x" + logos.sourceSize.height)
        }
    }

    // Main image part of the splash content screen.
    //   For documentation, see on bottomImage below.
    Image {
        id: topImage
        property real sourceAspectRatio

        fillMode: Image.PreserveAspectFit
        mipmap: true

        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(width * 1/sourceAspectRatio, parent.height)

        // Vertical space is distributed 2:1 between top and bottom image.
        Layout.maximumHeight: parent.height * 0.67

        Layout.alignment: horizontalAlignment | Qt.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter

        Component.onCompleted: {
            sourceAspectRatio = implicitWidth / implicitHeight
            topImage.sourceSize = scaleToFitSize(width, Layout.preferredHeight, sourceAspectRatio)
        }
    }

    // Footer image part of the splash content screen.
    //   Sizing terminology: there are actually three sizes, each one nested into the previous:
    //   (1) the container size of the surrounding element (container.width, container.height)
    //   (2) the image canvas size (bottomImage.width, bottomImage.height)
    //   (3) the actual image size, which can be smaller than the canvas due to "Image.PreserveAspectFit"
    //
    //   Sizing and positioning algorithm:
    //   (1) The image canvas width is calculated based on "Layout.fillWidth: true" and further
    //     constrained by Layout.maximumWidth.
    //   (2) The image canvas height is calculated as Layout.preferredHeight according to the source
    //     image proportions, and further constrained by Layout.maximumHeight.
    //   (3) The image is rendered to fit inside the canvas while preserving proportions, which
    //     means it might not fill the whole canvas.
    //   (4) The image is aligned inside its canvas and the canvas inside its container based on the
    //     defined alignment properties.
    //
    //   TODO Make the image size terminology and calculation simpler by calculating the image
    //   dimensions (in Layout.preferred*) ourselves in such a way that they already conform to the
    //   image aspect ratio.
    Image {
        id: bottomImage

        // Initial aspect ratio as derived from the source image.
        property real sourceAspectRatio

        fillMode: Image.PreserveAspectFit
        mipmap: true // Renders SVGs less blurry, esp. vertical and horizontal lines.

        // The basic constraint on canvas width: fill the available width up to Layout.maximumWidth.
        //   Without this, the image would have an initial size and maximum size, but not scale with
        //   the window size up and down.
        Layout.fillWidth: true

        // The basic constraint on canvas height: fill the available height up to Layout.maximumHeight.
        //   Without this, the image would have an initial size and maximum size, but not scale with
        //   the window size up and down. And when one dimension of the canvas does not scale, the
        //   image inside also cannot scale.
        //
        //   Usually this would be "Layout.fillHeight", in analogy to "Layout.fillWidth". However,
        //   that causes vertical alignment in Layout.alignment to stop working. For alignment, an
        //   element's height has to be smaller than the space it can be positioned in (here the
        //   parent element).
        //
        //   The max. image height is proportional to max. image width (= container width), and
        //   further constrained by the container height.
        //
        //   TODO: Shouldn't this be a minimum of three, also including Layout.maximumHeight?
        Layout.preferredHeight: Math.min(width * 1/sourceAspectRatio, parent.height)

        // Limit the image canvas width on large screens to keep this image visually a footer element.
        //   When this limit comes into effect, it overrides the width derived from "Layout.fillWidth".
        //
        //   We limit the desktop screen logo bounding box to 60%x25% of the window. But also
        //   show it at least in 540x216 px to be readable. When the parent element is smaller than
        //   that, the logos will be scaled to fit into it, and may then be unreadable (but that's ok).
        //   -1 keeps the property at its default value on mobile devices.
        //
        //   TODO: Expose the window percentage limit (currently 60%x25%) and static minimum size
        //   (currently 540x216 px) as properties of SplashContent.
        //
        //   TODO: On large tablet devices, limit logo size similarly.
        //
        //   TODO: Ideally, define the minium size in mm instead of 540x216 px.
        Layout.maximumWidth: (Kirigami.Settings.isMobile) ? -1 : Math.max(windowWidth * 0.6, 540)

        // Limit the image canvas height on large screens to keep this image visually a footer element.
        //   When this limit comes into effect, it overrides the width derived from "Layout.preferredHeight".
        //
        //   For the height constraints to keep it a footer element, see the comments on
        //   Layout.maximumWidth above. Additionally, it is limited to 33% of the container height
        //   because of distributing space between the top and bottom images.
        Layout.maximumHeight: {
            // Constraint to keep this element visually as a footer relative to the window size.
            var footerConstraint = Math.max(windowHeight * 0.25, 216)

            // Constraint to distribute vertical space 2:1 between top and bottom images.
            var containerConstraint = parent.height * 0.33

            if (Kirigami.Settings.isMobile)
                return containerConstraint
            else
                return Math.min(footerConstraint, containerConstraint)
        }

        // Define the horizontal and vertical alignment of the image.
        //   It is necessary to set both "Layout.alignment" and "horizontalAlignment". The former
        //   is for the alignment of the image inside its container, and the latter for the alignment
        //   of the drawn area inside the image canvas (which might not be filled because of
        //   Image.PreserveAspectFit).
        //
        //   Note that Image.horizontalAlignment usually takes values Image.AlignLeft etc.. But
        //   internally it uses the same data type Alignment, allowing interoperability with
        //   Layout.alignment as used here. See: https://doc.qt.io/qt-5/qt.html#AlignmentFlag-enum
        Layout.alignment: horizontalAlignment | Qt.AlignBottom
        horizontalAlignment: Qt.AlignHCenter // Default value. May be overwritten in client code.

        Component.onCompleted: {
            // implicitWidth and implicitHeight are set by the system based on the source size and
            // all configured scaling, fitting and cropping operations.
            sourceAspectRatio = implicitWidth / implicitHeight

            // Set the initial sourceSize according to the initial display size, to not hold excess data.
            //   Here, the "target rectangle" is the canvas available for drawing, namely "width"
            //   as set by "Layout.fillWidth" and "height" as set by "Layout.preferredHeight".
            //
            //   Placed here and not as a sourceSize property binding because we want to provide an
            //   initial value and then redraw only occasionally using the timer mechanism above.
            sourceSize = scaleToFitSize(width, Layout.preferredHeight, sourceAspectRatio)
            // console.log("SplashContent.qml: new sourceSize: " + sourceSize.width + "x" + sourceSize.height)
        }
    }

    // Placeholder to prevent the mobile UI from overlapping with the image rendered above.
    //   In the desktop version, nothing will overlap with the image rendered above, so if all
    //   exclusion areas are incorporated into the image as they should, its positioning is fine.
    //   However in the mobile interface of Kirigami applications, the left / main / right
    //   action buttons are displayed at the bottom, and will overlay the image. This is counteracted
    //   with this placeholder, so that the buttons will only overlay this placeholder, not the image.
    //
    //   Note that during some start sequences of the application in mobile mode under Android, the
    //   Kirigami action buttons will not overlay this placeholder but will be positioned below it.
    //   This seems to be a race condition bug in Kirigami and should not be relied on in any way.
    //
    //   TODO: Report the Kirigami bug mentioned above.
    //   TODO: Move this element to the client code of this QML type, as otherwise it ties this
    //   QML type to be positioned to the bottom of the page. It should be a generic type though.
    Rectangle {
        color: "transparent" // To help help debug page sizing, switch from "transparent" to "grey".
        Layout.fillWidth: true
        Layout.preferredHeight: 20
        visible: Kirigami.Settings.isMobile
    }
}
