#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

#include <QObject>
#include <QString>
#include <QVariant>
#include <QDebug>

#include <QFile>
#include <QFileInfo>
#include <QSysInfo>
#include <QStandardPaths>

#include "ContentDatabase.h"
#include "utilities.h"


ContentDatabase::ContentDatabase (QObject* parent) : QObject(parent) { }

/**
 * @brief Copies the specified Android asset to an ordinary file in a location accessible by this
 *   application. If a copy already exists, use that.
 * @param assetName Specifies an Android asset, using Qt's "asset:/folder/name.ext" scheme.
 * @return Absolute filename of the file containing the copy of the specified asset.
 */
static QString androidAssetToFile(QString assetPath) {

    if (!assetPath.startsWith("assets:/")) {
        qWarning()
            << "ContentDatabase::androidAssetToFile: ERROR: given name does not identify an asset:"
            << assetPath;
        return assetPath;
    }

    QFile asset(assetPath);
    if (!asset.exists()) {
        qWarning() << "ContentDatabase::androidAssetToFile: ERROR: given asset does not exist:" << assetPath;
        return "";
    }

    // Set the target filename to the same as in assetPath (remvoving "assets:/").
    QString fileName(assetPath);
    fileName.remove(0, 8);

    // Set the target directory.
    //   As of Qt 5.12, this sets the target directory to /data/user/0/com.example.appname/files/.
    //   In Android, all application data is stored per app and per user. Reportedly that directory
    //   symlinks to /data/data/com.example.appname/files/, from the old times when app data was
    //   not per-user. See: https://android.stackexchange.com/a/48397 .
    //
    //   When uninstalling the app, files in this directory are removed (see under "App-specific
    //   files" on https://developer.android.com/training/data-storage ). However, when upgrading
    //   the app (or reinstalling with "adb install -r"), files in this directory are not removed.
    QString fileDir;
    fileDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    if (fileDir.isEmpty()) {
        qDebug() << "ContentDatabase::androidAssetToFile: ERROR: Could not get a writable directory for app data.";
        return "";
    }

    // Construct the full absolute path to the target file.
    QFileInfo filePathInfo(QString("%1/%2").arg(fileDir).arg(fileName));
    QString filePath(filePathInfo.absoluteFilePath());
    qDebug()
        << "ContentDatabase::androidAssetToFile: INFO:"
        << "assetPath =" << assetPath << "filePath =" << filePath;

    // filePath = fileDir.append("/").append(fileName); // TODO: Old code v2, delete.
    // filePath = fileName.preprend(QString("/data/data/org.fairdirect.foodrescue/files")); // TODO: Old code v1, delete.

    QFile file(filePath);
    if (!file.exists()) {
        bool success = asset.copy(filePath);
        if (!success) {
            qDebug()
                << "ContentDatabase::androidAssetToFile: ERROR: Could not copy the Android asset"
                << assetPath << "to" << filePath;
            return "";
        }
        QFile::setPermissions(filePath, QFile::WriteOwner | QFile::ReadOwner);
    }
    // TODO: Return an error if the file exists but with a different file size.

    return filePath;
}


/**
 * @brief Connect to the content database file provided with the application.
 * @todo Use a proper path to the database file in desktop environments and iOS. It depends on
 *   where installers / packages install the database file.
 * @todo Make the path to the database file configurable as a method parameter because it
 *   depends on the environment and may also change when doing an update.
 */
void ContentDatabase::connect() {
    const QString DRIVER("QSQLITE");

    if(!QSqlDatabase::isDriverAvailable(DRIVER)) {
        // TODO: Rather throw an exception.
        qWarning() << "ContentDatabase::databaseConnect : ERROR: driver " << DRIVER << " not available";
        return;
    }

    // Set up the database connection as the default (unnamed) connection.
    //   This causes QSqlQuery etc. to use this connection by not specifying a connection name.
    //   See: https://doc.qt.io/qt-5/qsqldatabase.html#details
    QSqlDatabase db = QSqlDatabase::addDatabase(DRIVER);

    // Determine the SQLite database filename, depending on the operating system.
    qDebug() << "ContentDatabase::connect: QSysInfo::productType() = " << QSysInfo::productType();
    QString dbName;
    if (QSysInfo::productType() == "android") {
        // Under Android, the database is located in the "assets" folder of the APK package. Assets
        // can only be accessed via Qt's "assets" scheme, not directly via the file system.
        dbName = "assets:/foodrescue-content.sqlite3";

        // At first start under Android, copy the database to an ordinary file.
        //   The SQLite3 library can only access ordinary files via their file path, and Android assets
        //   residing inside the installed APK do not have an ordinary path in the underlying file
        //   system. See: https://stackoverflow.com/a/4820905 and https://stackoverflow.com/a/62596863
        dbName = androidAssetToFile(dbName);
    }
    else {
        // A path relative to the executable's current directory, usually its own directory.
        dbName = "foodrescue-content.sqlite3";
    }

    qDebug() << "ContentDatabase::connect: Database path used:" << dbName;

    // Make sure the database file exists.
    QFile dbFile(dbName);
    if (!dbFile.exists()) {
        qDebug() << "ContentDatabase::connect: ERROR: Database not found.";
        return;
    }

    // Open the database.
    //   Option QSQLITE_OPEN_READONLY prevents db.open() from silently creating an empty SQLite
    //   database. See: https://doc.qt.io/qt-5/qsqldatabase.html#setDatabaseName
    db.setConnectOptions("QSQLITE_OPEN_READONLY");
    db.setDatabaseName(dbName);
    qDebug() << "ContentDatabase::connect: Going to open database" << dbName;
    if(db.open()) {
        qDebug() << "ContentDatabase::connect: Database opened.";

        // TODO: Throw an error if the database does not have the expected table structure. That helps
        // to prevent surprises if the database file had been accidentally deleted and then automatically
        // re-creatd by db.open() above (which is what happens if the file is not found).
    }
    else {
        // TODO: Rather throw an exception.
        qWarning()
            << "ContentDatabase::connect: ERROR: could not open database "
            << dbName << ": " << db.lastError().text();
    }
}

/**
 * @brief Search the database for a barcode and return associated texts.
 * @param barcode Text as decoded from a barcode.
 * @return TODO
 */
QString ContentDatabase::search(QString barcode) {

    QSqlQuery query;

    // TODO: Chain the JOINs in the other direction because it's more logical. So
    //   it would be "SELECT FROM products … WHERE products.code = …" then.
    query.prepare(
        "SELECT title, content "
        "FROM topic_contents "
        "    INNER JOIN topics ON topic_contents.topic_id = topics.id "
        "    INNER JOIN topic_categories ON topics.id = topic_categories.topic_id "
        "    INNER JOIN product_categories ON topic_categories.topic_id = product_categories.category_id "
        "    INNER JOIN products ON product_categories.product_id = products.id "
        "WHERE products.code = :code"
    );
    query.bindValue(":code", barcode.toLongLong());
    // TODO: Check if the conversion was successful. See: https://doc.qt.io/qt-5/qstring.html#toLongLong

    qDebug() << "ContentDatabase::search: Value bound to: " << barcode.toLongLong();

    if(!query.exec())
        qWarning() << "ContentDatabase::search: ERROR: " << query.lastError().text();

    QString searchResult;

    while (query.next()) {
        searchResult
            .append("Title: ").append(query.value(0).toString()).append("\n\n")
            .append(query.value(1).toString()).append("\n\n");
    }

    if(searchResult.isEmpty())
        return QString("No content found.");
    else
        return searchResult;
}
