/**
 * Barcode scanner component, originally from https://github.com/swex/QZXingNu
 *
 * Authors and copyright:
 *   © 2018-2020  Alexey Mednyy    (https://github.com/swex)
 *   © 2020       Matthias Ansorg  (https://github.com/tanius)
 *
 * The authors license this file to you under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License. You may obtain a copy of the
 * License at: http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied.  See the License for the specific language governing permissions and
 * limitations under the License.
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import QtMultimedia 5.12
import org.kde.kirigami 2.10 as Kirigami
import local 1.0 as Local // Our custom QML components, exported in main.cpp.

// Sizing: The width of an OverlaySheet can be limited with Layout.preferredWidth and the content will
// adapt. But its height cannot be adapted – it is always as high as the content, potentially
// showing a scrollbar. To avoid the scrollbar, limit content height.

Kirigami.OverlaySheet {
    id: scannerOverlay

    property int tagsFound: 0
    property string lastTag: ""
    signal barcodeFound(string code)

    // Make the overlay "global", covering the whole window and not just one page column.
    parent: applicationWindow().overlay

    // TODO: Try moving the camera.stop() to onClose or similar, because showing the camera
    //   video output (and looking for barcodes) during the sheet closing animation is really slow.
    //   Mostly relevant for mobile platforms.
    onSheetOpenChanged: {
        // Activate the camera only while visible.
        //   Else it would consume energy and have its LED on permanently because OverlaySheet types
        //   are instantiated at the same time as their parent object. Relies on an initial camera
        //   state of Camera.UnloadedState.
        if(sheetOpen)
            camera.start()
        else
            camera.stop() // Triggered when manually closing scannerOverlay. See also onTagFound.

        if(sheetOpen) { tagsFound = 0; lastTag = ""; }
    }

    ColumnLayout {
        // Limit layout height to enable "Layout.fillHeight: true" for child VideoOutput.
        //   77% window height is the maximum possible for an overlay sheet without content
        //   scrolling in, and with a bottom margin the same size as the side margins.
        //
        //   TODO: Layout.maximumHeight does not work here. Why?
        //   TODO: Enable more height by making the larger top margin of OverlaySheet smaller.
        height: applicationWindow().height * 0.77

        // Spacings between video, camera list, status bar.
        spacing: Kirigami.Units.largeSpacing * 5

        // Barcode search algorithm, provided by ZXing-C++. Invisible.
        Local.BarcodeScanner {
            id: barcodeScanner

            // TODO: Make sure we include all necessary formats.
            formats: [Local.BarcodeFormat.EAN_13, Local.BarcodeFormat.EAN_8]
            tryHarder: true
            tryRotate: true // Also tries recognizing barcodes in a 90° rotated image.
            onDecodeResultChanged: console.log(decodeResult)
        }

        // Video filter looking for barcodes. Invisible.
        Local.BarcodeFilter {
            id: barcodeFilter
            onTagFound: {
                tagsFound++
                lastTag = tag
                // Stopping the camera now is needed because if done when closing the sheet would
                // keep it enabled long enough to sometimes recognize more barcodes.
                camera.stop()
                scannerOverlay.barcodeFound(tag)
                scannerOverlay.close()
            }
            scanner: barcodeScanner
        }

        // Configuration of device camera access. Invisible.
        Camera {
            function printViewfinderResolutions() {
                var resolutions = camera.supportedViewfinderResolutions();

                console.debug("Number of supported viewfinder resolutions: " + resolutions.length)

                for(var i=0; i<resolutions.length; i++) {
                    console.debug("resolution #" + i + ":" +
                        resolutions[i].width + "×" + resolutions[i].height
                    )
                }

                console.debug("Current resolution: " +
                    camera.viewfinder.resolution.width + "×" + camera.viewfinder.resolution.height
                )
            }

            id: camera

            // Prevent camera (as indicated by its LED) from switching on at application start.
            //   Because OverlaySheet is instantiated when its parent object is instantiated,
            //   and the default state is Camera.ActiveState. Using Camera.UnloadedState here
            //   would be even slightly better in terms of energy consumption, but would not allow
            //   setting the initial resolution simply with QML properties here.
            cameraState: Camera.LoadedState

            captureMode: Camera.CaptureViewfinder

            focus {
                // TODO: Only change focusMode if supported, to avoid messages like
                // "Focus mode selection is not supported".
                focusMode: CameraFocus.FocusContinuous
                focusPointMode: CameraFocus.FocusPointAuto
            }

            deviceId: {
                QtMultimedia.availableCameras[camerasComboBox.currentIndex] ?
                    QtMultimedia.availableCameras[camerasComboBox.currentIndex].deviceId : ""
            }

            // Workaround for a viewfinder image distortion bug on Asus Nexus 7 and other models.
            //   Basically, still image resolution has to match the preview size resolution.
            //   Background and solution details: https://stackoverflow.com/a/62541306
            //
            //   Setting imageCapture.resolution is a good workaround as it does not break any
            //   code for desktop systems, does not fail even when that resolution is not supported,
            //   and does not require any special-casing for devices or operating systems.
            //
            //   TODO: The current setting matches the default preview size of 1920x1020 on the
            //   Nexus 7. Make this solution generic for all devices with similar issues, according
            //   to the instructions on https://stackoverflow.com/a/62541306 .
            imageCapture {
                resolution: "1920x1080"
            }

            onCameraStateChanged: {
                // TODO: An event parameter "state" should be available but is empty. Maybe a bug?
                // TODO: Encapsulate this into a function, so there's just one line of code here.

                switch (cameraState) {
                case Camera.UnloadedState:
                    console.debug("New camera state: Camera.UnloadedState");
                    break;
                case Camera.LoadedState:
                    console.debug("New camera state: Camera.LoadedState");
                    printViewfinderResolutions()
                    break;
                case Camera.ActiveState:
                    console.debug("New camera state: Camera.ActiveState");
                    printViewfinderResolutions()
                    break;
                }
            }
            onDeviceIdChanged: {
                focus.focusMode = CameraFocus.FocusContinuous
                focus.focusPointMode = CameraFocus.FocusPointAuto
            }
            onLockStatusChanged: {
                if (tagDiscoveredInSession)
                    return
                if (lockStatus === Camera.Locked)
                    camera.unlock()
            }
            onError: console.log("camera error:" + errorString)
        }

        VideoOutput {
            id: viewFinder

            source: camera
            filters: [barcodeFilter]

            Layout.fillWidth: true  // Takes the width not taken by siblings.
            Layout.fillHeight: true // Takes the height not taken by siblings.
            fillMode: VideoOutput.PreserveAspectFit

            // TODO: Find out if excluding iOS here is still necessary.
            autoOrientation: Qt.platform.os == 'ios' ? false : true
            focus: visible // Captures key events only while visible.
        }

        // Camera chooser widget. Shown only when multiple cameras exist.
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            visible: QtMultimedia.availableCameras.length > 1
            Label {
                text: qsTr("Camera: ")
                Layout.fillWidth: false
            }
            ComboBox {
                id: camerasComboBox
                Layout.fillWidth: true
                model: QtMultimedia.availableCameras
                textRole: "displayName"
                currentIndex: 0
            }
        }

        // Status bar. Useful for debugging.
        Label {
            id: resultOutput
            text: "Barcodes found: " + tagsFound + (lastTag ? " Last barcode: " + lastTag : "")
        }
    }

}
