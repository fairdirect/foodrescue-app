#ifndef CONTENTDATABASE_H
#define CONTENTDATABASE_H

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>

#include <QString>
#include <QObject>

class ContentDatabase : public QObject {
   Q_OBJECT

public:
    explicit ContentDatabase (QObject* parent = 0);

    void connect();

    Q_INVOKABLE QString search(QString mInputText);
};

#endif // CONTENTDATABASE_H
