#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>
#include <QtXmlPatterns/QXmlQuery>

#include <QObject>
#include <QString>
#include <QRegularExpression>
#include <QVariant>
#include <QDebug>

#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>

#include "ContentDatabase.h"
#include "utilities.h"


/**
 * @brief Interface to a SQLite3 database with e-book like content.
 * @details The difference from typical e-book (such as EPUB) is that the content can be queried
 *   with a database interface. In this implementation (containing food rescue content), content
 *   can be queried based on product barcode or category, among others.
 */
ContentDatabase::ContentDatabase (QObject* parent) : QObject(parent) { }


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
    //   This causes QSqlQuery etc. to use this connection when no connection name is specified.
    //   This works even when accessing QSqlDatabase from different ContentDatabase objects.
    //   See: https://doc.qt.io/qt-5/qsqldatabase.html#details
    QSqlDatabase db = QSqlDatabase::addDatabase(DRIVER);

    // Determine the SQLite database filename, depending on the operating system.
    qDebug() << "ContentDatabase::connect: QSysInfo::productType() = " << QSysInfo::productType();
    QString dbName(""); // Initialize with a name of a non-existent file.
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
        // Look through Qt's app data directories from high to low priority and use the first DB file found.
        QStringList dbNameCandidates = QStandardPaths::standardLocations(QStandardPaths::AppLocalDataLocation);
        for (QString dbNameCandidate : dbNameCandidates) {
            dbNameCandidate += QString("/foodrescue-content.sqlite3");
            if (QFile::exists(dbNameCandidate)) dbName = dbNameCandidate;
        }
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
 * @brief Normalize the provided search term.
 * @param searchTerm The raw search term, usually as entered by a user.
 * @return The normalized search term. For example, leading and trailing spaces and spaces inside
 *   numerical search terms are removed.
 */
QString ContentDatabase::normalize(QString searchTerm) {
    QRegExp spacedNumber("[0-9 ]*");

    if (spacedNumber.exactMatch(searchTerm))
        return searchTerm.replace(" ", "");
    else
        return searchTerm.simplified(); // Trims whitespace and reduces other whitespace sequences to " ".
}


/**
 * @brief Provide search term auto-completion for the given text. Completion is right now done using
 *   only category names, but this may be extended later. Results are provided in member
 *   m_completionModel and to QML as property completionModel.
 * @param fragments  Space separated parts that must occur in this order as substrings in the
 *   auto-completion results.
 * @param limit  Maximum number of completion results to provide.
 */
void ContentDatabase::updateCompletions(QString fragments, int limit) {
    QSqlQuery query;
    QString searchTerm =  "%" + fragments.replace(" ", "%") + "%";

    // TODO Use a full-text index in this search for speed.
    query.prepare(
        "SELECT name "
        "FROM categories "
        "WHERE "
        "    lang LIKE 'en%' AND "
        "    name LIKE :searchTerm "
        "LIMIT :limit"
    );
    query.bindValue(":searchTerm", searchTerm);
    query.bindValue(":limit", limit);

    qDebug() << "ContentDatabase::completeCategory: Value bound to: " << searchTerm;

    m_completionModel.clear();

    // Execute the database query.
    if(!query.exec())
        qWarning() << "ContentDatabase::search: ERROR: " << query.lastError().text();
    else
        while (query.next()) {
            m_completionModel << query.value(0).toString();
        }

    qDebug() << "completionModel is now:" << m_completionModel;

    // Notify QML components and widgets using completionsModel to update their data.
    completionsChanged();
}


/**
 * @brief Search the database for a barcode and return associated topics in DocBook XML format.
 * @param searchTerm Text to use as the search term to find associated content topics in the
 *   database. This can be either text as decoded from a product barcode or a category name. The
 *   search term has to be in normalized format (see ContentDatabase::normalize()).
 * @return The content topics resulting from the database search, combined into a single DocBook
 *   XML document. All topic meta-information about the topics (author, content section,
 *   version date, categories etc.) is rendered into the returned document.
 */
QString ContentDatabase::contentAsDocbook(QString searchTerm) {

    QRegExp isNumber("[0-9]*");
    QSqlQuery query;

    if (isNumber.exactMatch(searchTerm)) {
        // Set up the query for a barcode number.
        // TODO: Chain the JOINs in the other direction because it's more logical. So
        //   it would be "SELECT FROM products … WHERE products.code = …" then.
        query.prepare(
            "SELECT topic_contents.title, topics.section, topics.version, topic_contents.content "
            "FROM topic_contents "
            "    INNER JOIN topics ON topic_contents.topic_id = topics.id "
            "    INNER JOIN topic_categories ON topics.id = topic_categories.topic_id "
            "    INNER JOIN product_categories ON topic_categories.category_id = product_categories.category_id "
            "    INNER JOIN products ON product_categories.product_id = products.id "
            "WHERE products.code = :code"
        );
        query.bindValue(":code", searchTerm.toLongLong());
        // TODO: Check if the conversion was successful. See: https://doc.qt.io/qt-5/qstring.html#toLongLong

        qDebug() << "ContentDatabase::search: Value bound to: " << searchTerm.toLongLong();
    }
    else {
        // Set up the query for a category name.
        query.prepare(
            "SELECT topic_contents.title, topics.section, topics.version, topic_contents.content "
            "FROM categories "
            "    INNER JOIN topic_categories ON topic_categories.category_id = categories.id "
            "    INNER JOIN topics ON topics.id = topic_categories.topic_id "
            "    INNER JOIN topic_contents ON topic_contents.topic_id = topics.id "
            "WHERE categories.name = :name COLLATE NOCASE;"
        );
        query.bindValue(":name", searchTerm);
    }

    // Execute the database query.
    if(!query.exec()) {
        // Return if there is nothing to render.
        qWarning() << "ContentDatabase::search: ERROR: " << query.lastError().text();
        return "";
    }

    // SQLite can't indicate search result size, so checking query.size() here is useless.

    // Render the search results into a simple DocBook "book" document.
    //   TODO: Also render the OFF category names into here.
    //   TODO: Also render the author names into here.
    //   TODO: Exchange this with a more readable single HTML string with %1, %2 etc. arguments.
    QString docbook;
    while (query.next()) {
        docbook
            .append("<topic type=\"").append(query.value(1).toString()).append("\">\n")
            .append("<info>\n")
            .append("<title>").append(query.value(0).toString()).append("</title>\n")
            .append("<edition><date>").append(query.value(2).toString()).append("</date></edition>")
            .append("</info>\n")
            .append(query.value(3).toString()) // Main content.
            .append("</topic>\n\n");
    }

    if (docbook.isEmpty())
        return "";
    else
        // TODO: Exchange this with a more readable single HTML string with %1 arguments.
        return docbook
            .prepend("<book xmlns=\"http://docbook.org/ns/docbook\" version=\"5.1\">\n")
            .append("</book>");
}


/**
 * @brief Search the database for a barcode and return associated topics.
 * @param searchTerm Text to use as the search term to find associated content topics in the
 *   database. This can be either text as decoded from a product barcode or a category name. The
 *   search term has to be in normalized format (see ContentDatabase::normalize()).
 * @param format The format to return the content in.
 * @return The content topics resulting from the database search, combined into a single DocBook
 *   XML or Qt5 HTML document. All topic meta-information about the topics (author, content section,
 *   version date, categories etc.) is rendered into the returned document.
 */
QString ContentDatabase::content(QString searchTerm, ContentFormat format) {

    // Get the raw database search results.
    QString docbook = contentAsDocbook(searchTerm);

    // Deal with the simple cases first.
    if (format == ContentFormat::DOCBOOK)
        return docbook;
    else if (docbook.isEmpty())
        return "";

    // Deal with the remaining case: converting the content to HTML format.
    QString html;
    QXmlQuery query(QXmlQuery::XSLT20);
    query.setFocus(docbook);
    query.setQuery(QUrl("qrc:/docbook-to-qthtml.xsl"));
    if (!query.isValid()) {
        qDebug() << "ContentDatabase::content(QString, ContentFormat): ERROR: "
            << "could not load query from qrc:/docbook-to-qthtml.xsl.";
    }
    query.evaluateTo(&html);

    qDebug().noquote()
        << "\nContentDatabase::content(QString, ContentFormat): Content in DocBook format:\n\n"
        << formatXml(docbook);
    qDebug().noquote()
        << "\nContentDatabase::content(QString, ContentFormat): Content in HTML format:\n\n"
        << formatXml(html);

    return html;
}


/**
 * @brief Search the database for a barcode and return bibliography items associated with any
 *   topic related to this barcode.
 * @param barcode Text as decoded from a barcode.
 * @return TODO
 */
QString ContentDatabase::literature(QString searchTerm) {
    // TODO: Implementation. Probably the return type has to be changed to a two-dimensional
    // array ("table" / "hash").
    return searchTerm; // Dummy, just to avoid the warnings.
}
