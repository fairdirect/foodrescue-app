#include <QCoreApplication>
#include <QtQml/QQmlEngine>
#include <ZXing/BarcodeFormat.h>
#include <ZXing/DecodeHints.h>
#include <ZXing/GenericLuminanceSource.h>
#include <ZXing/HybridBinarizer.h>
#include <ZXing/MultiFormatReader.h>
#include <ZXing/Result.h>

#include "BarcodeScanner.h"
#include "BarcodeFilter.h"

using ZXingFormats = std::vector<ZXing::BarcodeFormat>;
using ZXing::DecodeHints;
using ZXing::GenericLuminanceSource;
using ZXing::HybridBinarizer;
using ZXing::MultiFormatReader;
using ZXing::Result;

static QVector<QPointF> toQVectorOfQPoints(const std::vector<ZXing::ResultPoint>& points) {
    QVector<QPointF> result;
    for (const auto& point : points) {
        result.append(QPointF(point.x(), point.y()));
    }
    return result;
}

static Barcode::DecodeResult toDecodeResult(const ZXing::Result& result) {
    return { static_cast<Barcode::DecodeStatus>(result.status()),
        static_cast<Barcode::Format>(result.format()),
        QString::fromStdWString(result.text()),
        QByteArray(result.rawBytes().charPtr(), result.rawBytes().length()),
        toQVectorOfQPoints(result.resultPoints()),
        result.isValid() };
}

static ZXingFormats zxingFormats(const QVector<int>& from) {
    ZXingFormats result;
    result.reserve(static_cast<ZXingFormats::size_type>(from.size()));
    std::transform(from.begin(), from.end(), std::back_inserter(result),
        [](int a) { return static_cast<ZXing::BarcodeFormat>(a); });
    return result;
}

BarcodeScanner::BarcodeScanner(QObject* parent) : QObject(parent) {
    connect(this, &BarcodeScanner::queueDecodeResult, this, &BarcodeScanner::setDecodeResult);
}

QVector<int> BarcodeScanner::formats() const {
    return m_formats;
}

bool BarcodeScanner::tryHarder() const {
    return m_tryHarder;
}

bool BarcodeScanner::tryRotate() const {
    return m_tryRotate;
}

Barcode::DecodeResult BarcodeScanner::decodeResult() const {
    return m_decodeResult;
}

Barcode::DecodeResult BarcodeScanner::decodeImage(const QImage& image) {
    // reentrant
    auto luminanceSource = std::make_shared<GenericLuminanceSource>(image.width(), image.height(), image.bits(), image.bytesPerLine());
    DecodeHints hints;
    auto convertFormats = [this]() { return zxingFormats(m_formats); };
    hints.setPossibleFormats(convertFormats());
    hints.setTryHarder(m_tryHarder);
    hints.setTryRotate(m_tryRotate);
    MultiFormatReader reader(hints);
    auto readResult = reader.read(HybridBinarizer(luminanceSource));
    if (readResult.isValid()) {
        auto result = toDecodeResult(readResult);
        emit queueDecodeResult(result);
        return result;
    }
    return {};
}

void BarcodeScanner::setFormats(QVector<int> formats) {
    if (m_formats == formats)
        return;

    m_formats = formats;
    emit formatsChanged(m_formats);
}

void BarcodeScanner::setTryHarder(bool tryHarder) {
    if (m_tryHarder == tryHarder)
        return;

    m_tryHarder = tryHarder;
    emit tryHarderChanged(m_tryHarder);
}

void BarcodeScanner::setTryRotate(bool tryRotate) {
    if (m_tryRotate == tryRotate)
        return;

    m_tryRotate = tryRotate;
    emit tryRotateChanged(m_tryRotate);
}

void BarcodeScanner::setDecodeResult(Barcode::DecodeResult decodeResult) {
    m_decodeResult = decodeResult;
    emit decodeResultChanged(m_decodeResult);
}
