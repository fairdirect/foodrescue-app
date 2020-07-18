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

#pragma once

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
