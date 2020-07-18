/**
 * Utility datatypes for a QML barcode scanner component
 *
 * Part of a barcode scanner component, forked from https://github.com/swex/QZXingNu
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

#pragma once

#include <QImage>

/**
 * Container for status an format encoding types of barcodes.
 *
 * Note: Implementation with a namespace is necessary. Moving the enums into class BarcodeScanner
 * is not possible because struct DecodeResult depends on both the enums and class BarcodeScanner,
 * while that class in turn depends on DecodeResult, creating a circular header file dependency.
 * It cannot be solved with forward declarations because these are not possible for nested
 * enums inside a class (see https://stackoverflow.com/a/27019947 ). It cannot be solved with
 * opaque enum definitions either because of the circular dependency (compiler complains about
 * incomplete types). Finally, self-standing enum classes without an object cannot be exposed
 * to Qt QML, so we need a namespace (see https://www.kdab.com/new-qt-5-8-meta-object-support-namespaces/ ).
 *
 * TODO: A possibility to avoid the namespace could be to make struct DecodeResult a nested
 *   types of BarcodeScanner as well.
 */
namespace Barcode {

Q_NAMESPACE

/**
 * Identifier for the format of a barcode, as used by the ZXing C++ library.
 *
 * The values themselves are an implementation detail and simply have to be kept in sync with
 * the values used in the ZXing C++ library.
 *
 * TODO: This class is the same as ZXing::BarcodeFormat. Why can't we use that? Because like this,
 *   things break when ZXing::BarcodeFormat changes the assigned values. Which happened before.
 * TODO: Provide proper attribution to ZXing here, as this is code copied from them.
 */
enum class Format {
    // Note: ///< are Doxygen comments to document the preceding item.
    INVALID           = 0,           ///< Used as a return value if no valid barcode has been detected
    AZTEC             = (1 << 0),    ///< Aztec (2D)
    CODABAR           = (1 << 1),    ///< CODABAR (1D)
    CODE_39           = (1 << 2),    ///< Code 39 (1D)
    CODE_93           = (1 << 3),    ///< Code 93 (1D)
    CODE_128          = (1 << 4),    ///< Code 128 (1D)
    DATA_MATRIX       = (1 << 5),    ///< Data Matrix (2D)
    EAN_8             = (1 << 6),    ///< EAN-8 (1D)
    EAN_13            = (1 << 7),    ///< EAN-13 (1D)
    ITF               = (1 << 8),    ///< ITF (Interleaved Two of Five) (1D)
    MAXICODE          = (1 << 9),    ///< MaxiCode (2D)
    PDF_417           = (1 << 10),   ///< PDF417 (1D) or (2D)
    QR_CODE           = (1 << 11),   ///< QR Code (2D)
    RSS_14            = (1 << 12),   ///< RSS 14
    RSS_EXPANDED      = (1 << 13),   ///< RSS EXPANDED
    UPC_A             = (1 << 14),   ///< UPC-A (1D)
    UPC_E             = (1 << 15),   ///< UPC-E (1D)
    UPC_EAN_EXTENSION = (1 << 16),   ///< UPC/EAN extension (1D). Not a stand-alone format.

    LAST_FORMAT = UPC_EAN_EXTENSION, // For internal purpuses. Updated when adding new formats.
    FORMAT_COUNT = INVALID,          // Deprecated. Used before to count the number of formats.
};
Q_ENUM_NS(Format)


// TODO: Documentation.
enum class DecodeStatus {
    NoError = 0,
    NotFound,
    FormatError,
    ChecksumError,
};
Q_ENUM_NS(DecodeStatus)

// TODO: Documentation.
struct DecodeResult {
    Q_GADGET

    // Q_PROPERTY() needs to be used with fully qualified typenames ("Barcode::DecodeStatus").
    // Otherwise there will be a QML runtime error like "QMetaProperty::read: Unable to handle
    // unregistered datatype 'DecodeStatus' for property 'Barcode::DecodeResult::status'"
    Q_PROPERTY(Barcode::DecodeStatus status MEMBER status)
    Q_PROPERTY(Barcode::Format format MEMBER format)
    Q_PROPERTY(QString text MEMBER text)
    Q_PROPERTY(QByteArray rawBytes MEMBER rawBytes)
    Q_PROPERTY(QVector<QPointF> points MEMBER points)
    Q_PROPERTY(bool valid MEMBER valid)

public:
    Barcode::DecodeStatus status;
    Barcode::Format format;
    QString text;
    QByteArray rawBytes;
    QVector<QPointF> points;
    bool valid;
};

}

Q_DECLARE_METATYPE(Barcode::Format)
Q_DECLARE_METATYPE(Barcode::DecodeStatus)
Q_DECLARE_METATYPE(Barcode::DecodeResult)
