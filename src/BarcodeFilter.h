#ifndef BARCODEFILTER_H
#define BARCODEFILTER_H

#include <QAbstractVideoFilter>
#include <QThreadPool>
#include "BarcodeScanner.h"

class BarcodeFilter : public QAbstractVideoFilter {
    Q_OBJECT

    // Provide the BarcodeFilter.scanner QML property.
    Q_PROPERTY(BarcodeScanner *scanner READ scanner WRITE setScanner NOTIFY scannerChanged)

    // Provide the BarcodeFilter.decodeResult QML property.
    Q_PROPERTY(Barcode::DecodeResult decodeResult
        READ decodeResult WRITE setDecodeResult NOTIFY decodeResultChanged
    )

    BarcodeScanner* m_scanner = nullptr;
    QThreadPool* m_threadPool = nullptr;
    Barcode::DecodeResult m_decodeResult;
    int m_decodersRunning = 0;
    friend class BarcodeFilterRunnable;

public:
    BarcodeFilter(QObject *parent = nullptr);

    // QAbstractVideoFilter interface
public:
    QVideoFilterRunnable *createFilterRunnable() override;
    BarcodeScanner *scanner() const;
    Barcode::DecodeResult decodeResult() const;

signals:
    void tagFound(QString tag);
public slots:
    void setScanner(BarcodeScanner *scanner);
    void setDecodeResult(Barcode::DecodeResult decodeResult);

signals:
    void scannerChanged(BarcodeScanner *scanner);
    void decodeResultChanged(Barcode::DecodeResult decodeResult);
};

#endif // BARCODEFILTER_H
