#ifndef BARCODE_H
#define BARCODE_H

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
 * types of BarcodeScanner as well.
 */
namespace Barcode {

Q_NAMESPACE

enum class Format {
    /** Aztec 2D barcode format. */
    AZTEC,

    /** CODABAR 1D format. */
    CODABAR,

    /** Code 39 1D format. */
    CODE_39,

    /** Code 93 1D format. */
    CODE_93,

    /** Code 128 1D format. */
    CODE_128,

    /** Data Matrix 2D barcode format. */
    DATA_MATRIX,

    /** EAN-8 1D format. */
    EAN_8,

    /** EAN-13 1D format. */
    EAN_13,

    /** ITF (Interleaved Two of Five) 1D format. */
    ITF,

    /** MaxiCode 2D barcode format. */
    MAXICODE,

    /** PDF417 format. */
    PDF_417,

    /** QR Code 2D barcode format. */
    QR_CODE,

    /** RSS 14 */
    RSS_14,

    /** RSS EXPANDED */
    RSS_EXPANDED,

    /** UPC-A 1D format. */
    UPC_A,

    /** UPC-E 1D format. */
    UPC_E,

    /** UPC/EAN extension format. Not a stand-alone format. */
    UPC_EAN_EXTENSION,

    // Not valid value, used to count the number of formats, thus should be always the last
    // listed here
    FORMAT_COUNT,
};
Q_ENUM_NS(Format)


enum class DecodeStatus {
    NoError = 0,
    NotFound,
    FormatError,
    ChecksumError,
};
Q_ENUM_NS(DecodeStatus)


struct DecodeResult {

    Q_GADGET

    Q_PROPERTY(Barcode::DecodeStatus status MEMBER status)
    // Q_PROPERTY() needs to be called with fully qualified typenames always ("Barcode::Format").
    // Otherwise there will be a QML runtime error like "QMetaProperty::read: Unable to handle
    // unregistered datatype 'Format' for property 'Barcode::DecodeResult::format'"
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

#endif // BARCODE_H
