/**
 * Barcode scanner component, originally from https://github.com/swex/QZXingNu
 *
 * Authors and copyright:
 *   © Alexey Mednyy (https://github.com/swex) 2018-2020
 *   © Matthias Ansorg (https://github.com/tanius) 2020
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

    onSheetOpenChanged: {
        if(sheetOpen) {
            tagsFound = 0
            lastTag = ""

            // Keep camera active only while visible.
            //   Else the camera would consume energy and have its LED on all the time.
            camera.start()
        }
        else
            // In addition to onTagFound, to stop it also when manually closing OverlaySheet.
            camera.stop()
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

        // Invisible item providing the barcode recognition behavior.
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
            scanner: Local.BarcodeScanner {
                // TODO: Make sure we include all necessary formats.
                formats: [Local.BarcodeFormat.EAN_13, Local.BarcodeFormat.EAN_8]
                tryHarder: true
                tryRotate: true // Also try recognizing barcodes in a 90° rotated image.
                onDecodeResultChanged: console.log(decodeResult)
            }
        }

        VideoOutput {
            id: videoOutput

            // Take all width and height not taken by sibling items.
            Layout.fillWidth: true
            Layout.fillHeight: true

            autoOrientation: true
            fillMode: VideoOutput.PreserveAspectFit
            filters: [barcodeFilter]
            focus : visible // Capture keys only while visible.

            source: Camera {
                id: camera

                // Prevent camera (as indicated by its LED) from switching on at application start.
                //   Because OverlaySheet is instantiated when its parent object is instantiated,
                //   and the default state is Camera.ActiveState.
                cameraState: Camera.UnloadedState

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
                onDeviceIdChanged: {
                    focus.focusMode = CameraFocus.FocusContinuous
                    focus.focusPointMode = CameraFocus.FocusPointAuto
                    console.log("available resolutions: " + supportedViewfinderResolutions())
                }
                captureMode: Camera.CaptureViewfinder
                onLockStatusChanged: {
                    if (tagDiscoveredInSession)
                        return
                    if (lockStatus === Camera.Locked)
                        camera.unlock()
                }
                onError: console.log("camera error:" + errorString)
            }
        }

        // Camera chooser widget (shown if more than one camera exists).
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

        // Status bar, good for debugging.
        Label {
            id: resultOutput
            text: "Barcodes found: " + tagsFound + (lastTag ? " Last barcode: " + lastTag : "")
        }
    }

}
