#ifdef Q_OS_ANDROID
    #include <QGuiApplication>
    #include <QtAndroid>
#else
    #include <QApplication>
#endif

#include <QQmlApplicationEngine>


int main(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    #ifdef Q_OS_ANDROID
        QGuiApplication app(argc, argv);
    #else
        // Our QuickControls2 style for desktops requires a QApplication.
        QApplication app(argc, argv);
    #endif

    QQmlApplicationEngine engine;

    // Use different main files on desktop vs. mobile platform.
    // FIXME: Switch to the "qrc:/something" URLs if possible. So far not working.
    const QUrl desktopQML(QStringLiteral("qrc:///qml/BaseApp.qml"));
    const QUrl mobileQML(QStringLiteral("qrc:///qml/MobileApp.qml"));
    const bool QQC_MOBILE_SET(qEnvironmentVariableIsSet("QT_QUICK_CONTROLS_MOBILE"));
    const QString QQC_MOBILE(QString::fromLatin1(qgetenv("QT_QUICK_CONTROLS_MOBILE")));
    if (QQC_MOBILE_SET && (QQC_MOBILE == QStringLiteral("1") || QQC_MOBILE == QStringLiteral("true"))) {
        engine.load(mobileQML);
    } else {
        engine.load(desktopQML);
    }

    if (engine.rootObjects().isEmpty()) {
        QCoreApplication::exit(-1);
    }

    return app.exec();
}
