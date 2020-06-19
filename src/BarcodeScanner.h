#ifndef BARCODESCANNER_H
#define BARCODESCANNER_H

#include <QImage>
#include <QObject>
#include <memory>

#include "Barcode.h"

class BarcodeScanner : public QObject {

    Q_OBJECT
    Q_PROPERTY(QVector<int> formats READ formats WRITE setFormats NOTIFY formatsChanged)
    Q_PROPERTY(bool tryHarder READ tryHarder WRITE setTryHarder NOTIFY tryHarderChanged)
    Q_PROPERTY(bool tryRotate READ tryRotate WRITE setTryRotate NOTIFY tryRotateChanged)
    Q_PROPERTY(Barcode::DecodeResult decodeResult READ decodeResult NOTIFY decodeResultChanged)

public:
    explicit BarcodeScanner(QObject *parent = nullptr);

    QVector<int> formats() const;
    bool tryHarder() const;
    bool tryRotate() const;
    Barcode::DecodeResult decodeResult() const;

private:
    QVector<int> m_formats;
    bool m_tryHarder = false;
    bool m_tryRotate = false;
    Barcode::DecodeResult m_decodeResult;

signals:
    void imageDecoded(QString data);
    void formatsChanged(QVector<int> formats);
    void tryHarderChanged(bool tryHarder);
    void tryRotateChanged(bool tryRotate);
    void decodeResultChanged(Barcode::DecodeResult decodeResult);
    void queueDecodeResult(Barcode::DecodeResult result);
public slots:
    Barcode::DecodeResult decodeImage(const QImage &image);
    void setFormats(QVector<int> formats);
    void setTryHarder(bool tryHarder);
    void setTryRotate(bool tryRotate);

protected:
    void setDecodeResult(Barcode::DecodeResult decodeResult);
};

#endif // BARCODESCANNER_H
