#include "QZXingNuFilter.h"
#include "QZXingNu.h"
#include <QFutureWatcher>
#include <QPointer>
#include <QVariant>
#include <QVideoFilterRunnable>
#include <QtConcurrent>
#include <functional>
#include <memory>
#include <zxing-cpp/core/src/BarcodeFormat.h>
#include <zxing-cpp/core/src/DecodeHints.h>
#include <zxing-cpp/core/src/GenericLuminanceSource.h>
#include <zxing-cpp/core/src/HybridBinarizer.h>
#include <zxing-cpp/core/src/MultiFormatReader.h>
#include <zxing-cpp/core/src/Result.h>

namespace QZXingNu {

//as qt_imageFromVideoFrame is not public and stopped working for me in 5.13.1 I took frame2image convert code from from https://github.com/ftylitak/qzxing
namespace {
    struct CaptureRect;
    static QImage* rgbDataToGrayscale(const uchar* data, const CaptureRect& captureRect,
        const int alpha, const int red,
        const int green, const int blue,
        const bool isPremultiplied = false);
    bool isRectValid(const QRect& rect)
    {
        return rect.x() >= 0 && rect.y() >= 0 && rect.isValid();
    }

    uchar gray(uchar r, uchar g, uchar b)
    {
        return (306 * (r & 0xFF) + 601 * (g & 0xFF) + 117 * (b & 0xFF) + 0x200) >> 10;
    }
    uchar yuvToGray(uchar Y, uchar U, uchar V)
    {
        const int C = int(Y) - 16;
        const int D = int(U) - 128;
        const int E = int(V) - 128;
        return gray(
            qBound(0, ((298 * C + 409 * E + 128) >> 8), 255),
            qBound(0, ((298 * C - 100 * D - 208 * E + 128) >> 8), 255),
            qBound(0, ((298 * C + 516 * D + 128) >> 8), 255));
    }

    uchar yuvToGray2(uchar y, uchar u, uchar v)
    {
        double rD = y + 1.4075 * (v - 128);
        double gD = y - 0.3455 * (u - 128) - (0.7169 * (v - 128));
        double bD = y + 1.7790 * (u - 128);

        return gray(
            qBound<uchar>(0, (uchar)::floor(rD), 255),
            qBound<uchar>(0, (uchar)::floor(gD), 255),
            qBound<uchar>(0, (uchar)::floor(bD), 255));
    }

    struct CaptureRect {
        CaptureRect(const QRect& captureRect, int sourceWidth, int sourceHeight)
            : isValid(isRectValid(captureRect))
            , sourceWidth(sourceWidth)
            , sourceHeight(sourceHeight)
            , startX(isValid ? captureRect.x() : 0)
            , targetWidth(isValid ? captureRect.width() : sourceWidth)
            , endX(startX + targetWidth)
            , startY(isValid ? captureRect.y() : 0)
            , targetHeight(isValid ? captureRect.height() : sourceHeight)
            , endY(startY + targetHeight)
        {
        }

        bool isValid;
        char pad[3]; // avoid warning about padding

        int sourceWidth;
        int sourceHeight;

        int startX;
        int targetWidth;
        int endX;

        int startY;
        int targetHeight;
        int endY;
    };
    struct VideoFrameData {
        QByteArray data;
        QSize size;
        QVideoFrame::PixelFormat pixelFormat;

        VideoFrameData(QVideoFrame* frame)
        {
            frame->map(QAbstractVideoBuffer::ReadOnly);
            data.resize(frame->mappedBytes());
            memcpy(data.data(), frame->bits(), static_cast<size_t>(frame->mappedBytes()));
            size = frame->size();
            pixelFormat = frame->pixelFormat();
            frame->unmap();
        }
    };

    QImage* convertFrameToImage(QVideoFrame* input)
    {
        VideoFrameData simpleFrame(input);

        const int width = input->size().width();
        const int height = input->size().height();
        const CaptureRect captureRect(QRect(0, 0, width, height), width, height);
        const uchar* data = reinterpret_cast<const uchar*>(simpleFrame.data.constData());
        const uint32_t* yuvPtr = reinterpret_cast<const uint32_t*>(data);
        uchar* pixel;
        int wh;
        int w_2;
        int wh_54;

        /// Create QImage from QVideoFrame.
        QImage* image_ptr {};

        switch (input->pixelFormat()) {
        case QVideoFrame::Format_RGB32:
            image_ptr = rgbDataToGrayscale(data, captureRect, 0, 1, 2, 3);
            break;
        case QVideoFrame::Format_ARGB32:
            image_ptr = rgbDataToGrayscale(data, captureRect, 0, 1, 2, 3);
            break;
        case QVideoFrame::Format_ARGB32_Premultiplied:
            image_ptr = rgbDataToGrayscale(data, captureRect, 0, 1, 2, 3, true);
            break;
        case QVideoFrame::Format_BGRA32:
            image_ptr = rgbDataToGrayscale(data, captureRect, 3, 2, 1, 0);
            break;
        case QVideoFrame::Format_BGRA32_Premultiplied:
            image_ptr = rgbDataToGrayscale(data, captureRect, 3, 2, 1, 0, true);
            break;
        case QVideoFrame::Format_BGR32:
#if (QT_VERSION >= QT_VERSION_CHECK(5, 13, 0))
        case QVideoFrame::Format_ABGR32:
#endif
            image_ptr = rgbDataToGrayscale(data, captureRect, 3, 2, 1, 0);
            break;
        case QVideoFrame::Format_BGR24:
            image_ptr = rgbDataToGrayscale(data, captureRect, -1, 2, 1, 0);
            break;
        case QVideoFrame::Format_BGR555:
            /// This is a forced "conversion", colors end up swapped.
            image_ptr = new QImage(data, width, height, QImage::Format_RGB555);
            break;
        case QVideoFrame::Format_BGR565:
            /// This is a forced "conversion", colors end up swapped.
            image_ptr = new QImage(data, width, height, QImage::Format_RGB16);
            break;
        case QVideoFrame::Format_YUV420P:
        case QVideoFrame::Format_NV12:
            /// nv12 format, encountered on macOS
            image_ptr = new QImage(captureRect.targetWidth, captureRect.targetHeight, QImage::Format_Grayscale8);
            pixel = image_ptr->bits();
            wh = width * height;
            w_2 = width / 2;
            wh_54 = wh * 5 / 4;

            for (int y = captureRect.startY; y < captureRect.endY; y++) {
                const int Y_offset = y * width;
                const int y_2 = y / 2;
                const int U_offset = y_2 * w_2 + wh;
                const int V_offset = y_2 * w_2 + wh_54;
                for (int x = captureRect.startX; x < captureRect.endX; x++) {
                    const int x_2 = x / 2;
                    const uchar Y = data[Y_offset + x];
                    const uchar U = data[U_offset + x_2];
                    const uchar V = data[V_offset + x_2];
                    *pixel = yuvToGray(Y, U, V);
                    ++pixel;
                }
            }

            break;
        case QVideoFrame::Format_YUYV:
            image_ptr = new QImage(captureRect.targetWidth, captureRect.targetHeight, QImage::Format_Grayscale8);
            pixel = image_ptr->bits();

            for (int y = captureRect.startY; y < captureRect.endY; y++) {
                const uint32_t* row = &yuvPtr[y * (width / 2)];
                int end = captureRect.startX / 2 + (captureRect.endX - captureRect.startX) / 2;
                for (int x = captureRect.startX / 2; x < end; x++) {
                    const uint8_t* pxl = reinterpret_cast<const uint8_t*>(&row[x]);
                    const uint8_t y0 = pxl[0];
                    const uint8_t u = pxl[1];
                    const uint8_t v = pxl[3];
                    const uint8_t y1 = pxl[2];

                    *pixel = yuvToGray2(y0, u, v);
                    ++pixel;
                    *pixel = yuvToGray2(y1, u, v);
                    ++pixel;
                }
            }

            break;
            /// TODO: Handle (create QImages from) YUV formats.
        default:
            QImage::Format imageFormat = QVideoFrame::imageFormatFromPixelFormat(input->pixelFormat());
            image_ptr = new QImage(data, width, height, imageFormat);
            break;
        }
        return image_ptr;
    }
    static QImage* rgbDataToGrayscale(const uchar* data, const CaptureRect& captureRect,
        const int alpha, const int red,
        const int green, const int blue,
        const bool isPremultiplied)
    {
        const int stride = (alpha < 0) ? 3 : 4;

        const int endX = captureRect.sourceWidth - captureRect.startX - captureRect.targetWidth;
        const int skipX = (endX + captureRect.startX) * stride;

        QImage* image_ptr = new QImage(captureRect.targetWidth, captureRect.targetHeight, QImage::Format_Grayscale8);
        uchar* pixelInit = image_ptr->bits();
        data += (captureRect.startY * captureRect.sourceWidth + captureRect.startX) * stride;
        for (int y = 1; y <= captureRect.targetHeight; ++y) {

            //Quick fix for iOS devices. Will be handled better in the future
#ifdef Q_OS_IOS
            uchar* pixel = pixelInit + (y - 1) * captureRect.targetWidth;
#else
            uchar* pixel = pixelInit + (captureRect.targetHeight - y) * captureRect.targetWidth;
#endif
            for (int x = 0; x < captureRect.targetWidth; ++x) {
                uchar r = data[red];
                uchar g = data[green];
                uchar b = data[blue];
                if (isPremultiplied) {
                    uchar a = data[alpha];
                    r = uchar((uint(r) * 255) / a);
                    g = uchar((uint(g) * 255) / a);
                    b = uchar((uint(b) * 255) / a);
                }
                *pixel = gray(r, g, b);
                ++pixel;
                data += stride;
            }
            data += skipX;
        }

        return image_ptr;
    }

}

class QZXingNuFilterRunnable : public QObject, public QVideoFilterRunnable {

    QZXingNuFilter *m_filter = nullptr;

public:
    explicit QZXingNuFilterRunnable(QZXingNuFilter *filter, QObject *parent = nullptr)
        : QObject(parent)
        , m_filter(filter)
    {
    }

    QVideoFrame run(QVideoFrame *input, const QVideoSurfaceFormat & /*surfaceFormat*/,
                    RunFlags /*flags*/) override
    {
        static auto ourIdealThreadCount = m_filter->m_threadPool->maxThreadCount();
        if (m_filter == nullptr) {
            qWarning() << "filter null";
            return *input;
        }
        if (!input->isValid()) {
            qWarning() << "input invalid";
            return *input;
        }
        if (m_filter->m_decodersRunning >= ourIdealThreadCount) {
            return *input;
        }
        auto image_ptr = convertFrameToImage(input);
        m_filter->m_decodersRunning++;

        auto bound = std::bind(&QZXingNu::decodeImage, m_filter->m_qzxingNu, std::placeholders::_1);
        auto watcher = new QFutureWatcher<QZXingNuDecodeResult>();
        QPointer<QZXingNuFilter> filterPointer(m_filter);
        QObject::connect(watcher, &QFutureWatcher<QZXingNuDecodeResult>::finished, this,
            [watcher, image_ptr, filterPointer]() {
                if (!filterPointer.isNull()) {
                    filterPointer->m_decodersRunning--;
                }
                auto result = watcher->future().result();
                delete watcher;
                delete image_ptr;
            });
        auto future = QtConcurrent::run(m_filter->m_threadPool, bound, *image_ptr);
        watcher->setFuture(future);
        return *input;
    }
};

QZXingNuFilter::QZXingNuFilter(QObject* parent)
    : QAbstractVideoFilter(parent)
    , m_threadPool(new QThreadPool(this))
{
    m_threadPool->setMaxThreadCount(QThread::idealThreadCount() > 1
            ? QThread::idealThreadCount() - 1
            : QThread::idealThreadCount());
    connect(this, &QZXingNuFilter::qzxingNuChanged, this, [this]() {
        connect(m_qzxingNu, &QZXingNu::decodeResultChanged, this, &QZXingNuFilter::setDecodeResult);
    });
    connect(this, &QZXingNuFilter::decodeResultChanged, this,
            [this]() { emit tagFound(m_decodeResult.text); });
}

QVideoFilterRunnable *QZXingNuFilter::createFilterRunnable()
{
    return new QZXingNuFilterRunnable(this);
}

QZXingNu *QZXingNuFilter::qzxingNu() const
{
    return m_qzxingNu;
}

QZXingNuDecodeResult QZXingNuFilter::decodeResult() const
{
    return m_decodeResult;
}

void QZXingNuFilter::setQzxingNu(QZXingNu *qzxingNu)
{
    if (m_qzxingNu == qzxingNu)
        return;

    m_qzxingNu = qzxingNu;
    emit qzxingNuChanged(m_qzxingNu);
}

void QZXingNuFilter::setDecodeResult(QZXingNuDecodeResult decodeResult)
{
    m_decodeResult = decodeResult;
    emit decodeResultChanged(m_decodeResult);
}
} // namespace QZXingNu
