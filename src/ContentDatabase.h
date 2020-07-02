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

    QString contentAsDocbook(QString barcode);

    Q_INVOKABLE QString content(QString barcode, ContentFormat format = ContentFormat::HTML);

    QString literature(QString barcode);
};

#endif // CONTENTDATABASE_H
