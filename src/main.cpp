#ifdef Q_OS_ANDROID
    #include <QGuiApplication>
    #include <QtAndroid>
#else
    #include <QApplication>
#endif

#include <QQmlApplicationEngine>
#include <QDebug>
#include "ContentDatabase.h"
#include "utilities.h"

// Export main() as part of a library interface. Needed on Android.
//   Q_DECL_EXPORT is a Qt MOC macro that exposes main() as part of the interface of a
//   library; see https://stackoverflow.com/q/13911387. Building and executing works
//   without this for desktop software. But on Android, a native application is loaded
//   as a library from some Java bootstrap code, so it's needed there. Otherwise, the
//   build process fails with "Could not find a main() symbol". See
//   https://phabricator.kde.org/D12120
Q_DECL_EXPORT
int main(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    #ifdef Q_OS_ANDROID
        QGuiApplication app(argc, argv);
    #else
        // Our QuickControls2 style for desktops requires a QApplication.
        QApplication app(argc, argv);
    #endif

    // Create and initialize the Food Rescue SQLite3 database connection.
    ContentDatabase db;
    db.connect();

    // Make the Food Rescue database available for use in QML.
    // TODO: Better than registering the type to be instantiated in QML, provide the above "db"
    // object as a global object to be accessed in QML.
    qmlRegisterType<ContentDatabase>("local", 1, 0, "ContentDatabase");

    QQmlApplicationEngine engine;

    // Use different main files on desktop vs. mobile platform.
    // TODO: Switch to the "qrc:/something" URLs if possible. So far not working.
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
