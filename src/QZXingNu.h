#ifndef QZXINGNU_H
#define QZXINGNU_H

#include <QImage>
#include <QObject>
#include <memory>

namespace QZXingNu {

Q_NAMESPACE

enum class BarcodeFormat {
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
Q_ENUM_NS(BarcodeFormat)

enum class DecodeStatus {
    NoError = 0,
    NotFound,
    FormatError,
    ChecksumError,
};
Q_ENUM_NS(DecodeStatus)

struct QZXingNuDecodeResult
{
    Q_GADGET
    Q_PROPERTY(DecodeStatus status MEMBER status)
    Q_PROPERTY(BarcodeFormat format MEMBER format)
    Q_PROPERTY(QString text MEMBER text)
    Q_PROPERTY(QByteArray rawBytes MEMBER rawBytes)
    Q_PROPERTY(QVector<QPointF> points MEMBER points)
    Q_PROPERTY(bool valid MEMBER valid)

public:
    DecodeStatus status;
    BarcodeFormat format;
    QString text;
    QByteArray rawBytes;
    QVector<QPointF> points;
    bool valid;
};

class QZXingNu : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVector<int> formats READ formats WRITE setFormats NOTIFY formatsChanged)
    Q_PROPERTY(bool tryHarder READ tryHarder WRITE setTryHarder NOTIFY tryHarderChanged)
    Q_PROPERTY(bool tryRotate READ tryRotate WRITE setTryRotate NOTIFY tryRotateChanged)
    Q_PROPERTY(QZXingNuDecodeResult decodeResult READ decodeResult NOTIFY decodeResultChanged)
    QVector<int> m_formats;
    bool m_tryHarder = false;
    bool m_tryRotate = false;
    QZXingNuDecodeResult m_decodeResult;

public:
    explicit QZXingNu(QObject *parent = nullptr);
    QVector<int> formats() const;
    bool tryHarder() const;
    bool tryRotate() const;
    QZXingNuDecodeResult decodeResult() const;

signals:
    void imageDecoded(QString data);
    void formatsChanged(QVector<int> formats);
    void tryHarderChanged(bool tryHarder);
    void tryRotateChanged(bool tryRotate);
    void decodeResultChanged(QZXingNuDecodeResult decodeResult);
    void queueDecodeResult(QZXingNuDecodeResult result);
public slots:
    QZXingNuDecodeResult decodeImage(const QImage &image);
    void setFormats(QVector<int> formats);
    void setTryHarder(bool tryHarder);
    void setTryRotate(bool tryRotate);

protected:
    void setDecodeResult(QZXingNuDecodeResult decodeResult);
};
} // namespace QZXingNu

Q_DECLARE_METATYPE(QZXingNu::BarcodeFormat)
Q_DECLARE_METATYPE(QZXingNu::DecodeStatus)
Q_DECLARE_METATYPE(QZXingNu::QZXingNuDecodeResult)

#endif // QZXINGNU_H
