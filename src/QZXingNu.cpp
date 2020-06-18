#include "QZXingNu.h"
#include "QZXingNuFilter.h"
#include <QCoreApplication>
#include <QtQml/QQmlEngine>
#include <zxing-cpp/core/src/BarcodeFormat.h>
#include <zxing-cpp/core/src/DecodeHints.h>
#include <zxing-cpp/core/src/GenericLuminanceSource.h>
#include <zxing-cpp/core/src/HybridBinarizer.h>
#include <zxing-cpp/core/src/MultiFormatReader.h>
#include <zxing-cpp/core/src/Result.h>

namespace QZXingNu {

using ZXingFormats = std::vector<ZXing::BarcodeFormat>;
using ZXing::DecodeHints;
using ZXing::GenericLuminanceSource;
using ZXing::HybridBinarizer;
using ZXing::MultiFormatReader;
using ZXing::Result;

static QVector<QPointF> toQVectorOfQPoints(const std::vector<ZXing::ResultPoint>& points)
{
    QVector<QPointF> result;
    for (const auto& point : points) {
        result.append(QPointF(point.x(), point.y()));
    }
    return result;
}

static QZXingNuDecodeResult toQZXingNuDecodeResult(const ZXing::Result& result)
{
    return { static_cast<DecodeStatus>(result.status()),
        static_cast<BarcodeFormat>(result.format()),
        QString::fromStdWString(result.text()),
        QByteArray(result.rawBytes().charPtr(), result.rawBytes().length()),
        toQVectorOfQPoints(result.resultPoints()),
        result.isValid() };
}
static ZXingFormats zxingFormats(const QVector<int>& from)
{
    ZXingFormats result;
    result.reserve(static_cast<ZXingFormats::size_type>(from.size()));
    std::transform(from.begin(), from.end(), std::back_inserter(result),
        [](int a) { return static_cast<ZXing::BarcodeFormat>(a); });
    return result;
}

QZXingNu::QZXingNu(QObject* parent)
    : QObject(parent)
{
    connect(this, &QZXingNu::queueDecodeResult, this, &QZXingNu::setDecodeResult);
}

QVector<int> QZXingNu::formats() const
{
    return m_formats;
}

bool QZXingNu::tryHarder() const
{
    return m_tryHarder;
}

bool QZXingNu::tryRotate() const
{
    return m_tryRotate;
}

QZXingNuDecodeResult QZXingNu::decodeResult() const
{
    return m_decodeResult;
}

QZXingNuDecodeResult QZXingNu::decodeImage(const QImage& image)
{
    // reentrant
    auto luminanceSource = std::make_shared<GenericLuminanceSource>(image.width(), image.height(), image.bits(), image.bytesPerLine());
    DecodeHints hints;
    auto convertFormats = [this]() { return zxingFormats(m_formats); };
    hints.setPossibleFormats(convertFormats());
    hints.setTryHarder(m_tryHarder);
    hints.setTryRotate(m_tryRotate);
    MultiFormatReader reader(hints);
    auto result = reader.read(HybridBinarizer(luminanceSource));
    if (result.isValid()) {
        auto qzxingResult = toQZXingNuDecodeResult(result);
        emit queueDecodeResult(qzxingResult);
        return qzxingResult;
    }
    return {};
}

void QZXingNu::setFormats(QVector<int> formats)
{
    if (m_formats == formats)
        return;

    m_formats = formats;
    emit formatsChanged(m_formats);
}

void QZXingNu::setTryHarder(bool tryHarder)
{
    if (m_tryHarder == tryHarder)
        return;

    m_tryHarder = tryHarder;
    emit tryHarderChanged(m_tryHarder);
}

void QZXingNu::setTryRotate(bool tryRotate)
{
    if (m_tryRotate == tryRotate)
        return;

    m_tryRotate = tryRotate;
    emit tryRotateChanged(m_tryRotate);
}

void QZXingNu::setDecodeResult(QZXingNuDecodeResult decodeResult)
{
    m_decodeResult = decodeResult;
    emit decodeResultChanged(m_decodeResult);
}
} // namespace QZXingNu
