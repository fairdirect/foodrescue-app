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
import QtQuick.Window 2.12
import QtMultimedia 5.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.10

// Import our custom QML components ("ContentDatabase" etc.), exported in main.cpp.
import local 1.0 as Local

Page {

    visible: true
//    width: 640
//    height: 480
//    title: Qt.application.name

    Layout.fillHeight: true
    Layout.fillWidth: true

    property int tagsFound: 0
    property string lastTag: ""
    ColumnLayout {
        anchors.fill: parent
        Local.BarcodeFilter {
            id: barcodeFilter
            onTagFound: {
                tagsFound++
                lastTag = tag
            }
            scanner: Local.BarcodeScanner {
                // TODO: Make sure we include all necessary formats.
                formats: [Local.BarcodeFormat.EAN_13]
                onDecodeResultChanged: console.log(decodeResult)
            }
        }

        VideoOutput {
            id: videoOutput
            fillMode: VideoOutput.PreserveAspectCrop
            Layout.fillHeight: true
            Layout.fillWidth: true
            filters: [barcodeFilter]
            source: Camera {
                id: camera
                focus {
                    focusMode: CameraFocus.FocusContinuous
                    focusPointMode: CameraFocus.FocusPointAuto
                }
                deviceId: {
                    QtMultimedia.availableCameras[camerasComboBox.currentIndex] ?
                        QtMultimedia.availableCameras[camerasComboBox.currentIndex].deviceId : ""
                }
                onDeviceIdChanged: {
                    console.log("avaliable resolutions: " + supportedViewfinderResolutions(
                                    ))
                    focus.focusMode = CameraFocus.FocusContinuous
                    focus.focusPointMode = CameraFocus.FocusPointAuto
                }
                captureMode: Camera.CaptureViewfinder
                onCameraStateChanged: {

                }
                onLockStatusChanged: {
                    if (tagDiscoveredInSession) {
                        return
                    }
                    if (lockStatus === Camera.Locked) {
                        camera.unlock()
                    }
                }
                onError: console.log("camera error:" + errorString)
            }
            autoOrientation: true
        }

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
        Label {
            id: resultOutput
            text: "tags found: " + tagsFound + (lastTag ? " last tag: " + lastTag : "")
        }
    }
}
