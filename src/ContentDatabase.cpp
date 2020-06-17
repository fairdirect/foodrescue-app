#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

#include <QObject>
#include <QString>
#include <QVariant>
#include <QDebug>

#include "ContentDatabase.h"
#include "utilities.h"


ContentDatabase::ContentDatabase (QObject* parent) : QObject(parent) { }

/**
 * Connect to the content database file provided with the application.
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

    // Open this SQLite3 file. The path is relative to the executable's location.
    // TODO: The path should be provided as a method parameter because it depends on the
    //   environment and may also change when doing an update.
    // TODO: Provide a proper path in desktop environments. It depends on where installers /
    //   packages install the database file.
    // TODO: Provide the correct path for Android and iOS.
    db.setDatabaseName("foodrescue-content.sqlite3");

    if(!db.open()) {
        // TODO: Rather throw an exception.
        qWarning() << "MainWindow::DatabaseConnect: ERROR: " << db.lastError().text();
        return;
    }
}


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
        "WHERE products.code = ?"
    );
    query.addBindValue(barcode.toLongLong());
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
