#ifndef CONTENTDATABASE_H
#define CONTENTDATABASE_H

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

#include <QString>
#include <QObject>

enum ContentFormat {DOCBOOK, HTML};

class ContentDatabase : public QObject {
   Q_OBJECT

public:
    explicit ContentDatabase (QObject* parent = 0);

    void connect();

    Q_INVOKABLE // Allows to invoke this method from QML.
    QString normalize(QString searchTerm);

    QString contentAsDocbook(QString barcode);

    Q_INVOKABLE // Allows to invoke this method from QML.
    QString content(QString searchTerm, ContentFormat format = ContentFormat::HTML);

    QString literature(QString searchTerm);
};

#endif // CONTENTDATABASE_H
