/**
 * Main QML type of a QML barcode scanner component
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

#include <QCoreApplication>
#include <QtQml/QQmlEngine>
#include <ZXing/BarcodeFormat.h>
#include <ZXing/DecodeHints.h>
#include <ZXing/GenericLuminanceSource.h>
#include <ZXing/HybridBinarizer.h>
#include <ZXing/MultiFormatReader.h>
#include <ZXing/Result.h>

#include "Barcode.h"
#include "BarcodeScanner.h"
#include "BarcodeFilter.h"

using ZXingFormats = std::vector<ZXing::BarcodeFormat>;
using ZXing::DecodeHints;
using ZXing::GenericLuminanceSource;
using ZXing::HybridBinarizer;
using ZXing::MultiFormatReader;
using ZXing::Result;

// TODO: Documentation.
// TODO: Try to outsource this utility method to Barcode.h, since it's not part of class BarcodeScanner.
static QVector<QPointF> toQVectorOfQPoints(const std::vector<ZXing::ResultPoint>& points) {
    QVector<QPointF> result;
    for (const auto& point : points) {
        result.append(QPointF(point.x(), point.y()));
    }
    return result;
}

// TODO: Documentation.
// TODO: Try to outsource this utility method to Barcode.h, since it's not part of class BarcodeScanner.
static Barcode::DecodeResult toDecodeResult(const ZXing::Result& result) {
    return { static_cast<Barcode::DecodeStatus>(result.status()),
        static_cast<Barcode::Format>(result.format()),
        QString::fromStdWString(result.text()),
        QByteArray(result.rawBytes().charPtr(), result.rawBytes().length()),
        toQVectorOfQPoints(result.resultPoints()),
        result.isValid() };
}

// TODO: Documentation.
// TODO: Try to outsource this utility method to Barcode.h, since it's not part of class BarcodeScanner.
static ZXingFormats zxingFormats(const QVector<int>& from) {
    ZXingFormats result;
    result.reserve(static_cast<ZXingFormats::size_type>(from.size()));
    std::transform(
        from.begin(),
        from.end(),
        std::back_inserter(result),
        [](int a) { return static_cast<ZXing::BarcodeFormat>(a); }
    );
    return result;
}


// TODO: Documentation.
BarcodeScanner::BarcodeScanner(QObject* parent) : QObject(parent) {
    connect(this, &BarcodeScanner::queueDecodeResult, this, &BarcodeScanner::setDecodeResult);
}

// TODO: Documentation.
QVector<int> BarcodeScanner::formats() const {
    return m_formats;
}

// TODO: Documentation.
bool BarcodeScanner::tryHarder() const {
    return m_tryHarder;
}

// TODO: Documentation.
bool BarcodeScanner::tryRotate() const {
    return m_tryRotate;
}

// TODO: Documentation.
Barcode::DecodeResult BarcodeScanner::decodeResult() const {
    return m_decodeResult;
}

// TODO: Documentation.
// Reentrant implementation, allows decoding with multiple threads in parallel.
Barcode::DecodeResult BarcodeScanner::decodeImage(const QImage& image) {
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

// TODO: Documentation.
void BarcodeScanner::setFormats(QVector<int> formats) {
    if (m_formats == formats)
        return;

    m_formats = formats;
    emit formatsChanged(m_formats);
}

// TODO: Documentation.
void BarcodeScanner::setTryHarder(bool tryHarder) {
    if (m_tryHarder == tryHarder)
        return;

    m_tryHarder = tryHarder;
    emit tryHarderChanged(m_tryHarder);
}

// TODO: Documentation.
void BarcodeScanner::setTryRotate(bool tryRotate) {
    if (m_tryRotate == tryRotate)
        return;

    m_tryRotate = tryRotate;
    emit tryRotateChanged(m_tryRotate);
}

// TODO: Documentation.
void BarcodeScanner::setDecodeResult(Barcode::DecodeResult decodeResult) {
    m_decodeResult = decodeResult;
    emit decodeResultChanged(m_decodeResult);
}
