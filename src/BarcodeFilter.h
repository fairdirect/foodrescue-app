/**
 * Barcode-detecting QML video filter
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
