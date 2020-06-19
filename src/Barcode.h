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

// TODO: This class is the same as ZXing::BarcodeFormat. Why can't we use that? Because like this,
//   things break when ZXing::BarcodeFormat changes the assigned values. Which happened before.
enum class Format {
    // The values are an implementation detail. The c++ use-case (ZXFlags) could have been designed to such that, it
    // would not have been necessary to explicitly set the values to single bit constants. This has been done to ease
    // the interoperability with C-like interfaces, the python and the Qt wrapper.
    INVALID           = 0,         ///< Used as a return value if no valid barcode has been detected
    AZTEC             = (1 << 0),  ///< Aztec (2D)
    CODABAR           = (1 << 1),  ///< CODABAR (1D)
    CODE_39           = (1 << 2),  ///< Code 39 (1D)
    CODE_93           = (1 << 3),  ///< Code 93 (1D)
    CODE_128          = (1 << 4),  ///< Code 128 (1D)
    DATA_MATRIX       = (1 << 5),  ///< Data Matrix (2D)
    EAN_8             = (1 << 6),  ///< EAN-8 (1D)
    EAN_13            = (1 << 7),  ///< EAN-13 (1D)
    ITF               = (1 << 8),  ///< ITF (Interleaved Two of Five) (1D)
    MAXICODE          = (1 << 9),  ///< MaxiCode (2D)
    PDF_417           = (1 << 10), ///< PDF417 (1D) or (2D)
    QR_CODE           = (1 << 11), ///< QR Code (2D)
    RSS_14            = (1 << 12), ///< RSS 14
    RSS_EXPANDED      = (1 << 13), ///< RSS EXPANDED
    UPC_A             = (1 << 14), ///< UPC-A (1D)
    UPC_E             = (1 << 15), ///< UPC-E (1D)
    UPC_EAN_EXTENSION = (1 << 16), ///< UPC/EAN extension (1D). Not a stand-alone format.

    // used for internal purpuses, check after adding new formats
    LAST_FORMAT = UPC_EAN_EXTENSION,
    // Used to count the number of formats, now deprecated
    FORMAT_COUNT = INVALID,
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
