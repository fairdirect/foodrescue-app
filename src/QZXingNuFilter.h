#ifndef QZXINGNUFILTER_H
#define QZXINGNUFILTER_H

#include <QAbstractVideoFilter>
#include <QThreadPool>
#include "QZXingNu.h"

namespace QZXingNu {

class QZXingNuFilter : public QAbstractVideoFilter {
    Q_OBJECT
    Q_PROPERTY(QZXingNu *qzxingNu READ qzxingNu WRITE setQzxingNu NOTIFY qzxingNuChanged)
    Q_PROPERTY(QZXingNuDecodeResult decodeResult READ decodeResult WRITE setDecodeResult NOTIFY decodeResultChanged)
    QZXingNu* m_qzxingNu = nullptr;
    QThreadPool* m_threadPool = nullptr;
    QZXingNuDecodeResult m_decodeResult;
    int m_decodersRunning = 0;
    friend class QZXingNuFilterRunnable;

public:
    QZXingNuFilter(QObject *parent = nullptr);

    // QAbstractVideoFilter interface
public:
    QVideoFilterRunnable *createFilterRunnable() override;
    QZXingNu *qzxingNu() const;
    QZXingNuDecodeResult decodeResult() const;

signals:
    void tagFound(QString tag);
public slots:
    void setQzxingNu(QZXingNu *qzxingNu);
    void setDecodeResult(QZXingNuDecodeResult decodeResult);

signals:
    void qzxingNuChanged(QZXingNu *qzxingNu);
    void decodeResultChanged(QZXingNuDecodeResult decodeResult);
};

} // namespace QZXingNu
#endif // QZXINGNUFILTER_H
