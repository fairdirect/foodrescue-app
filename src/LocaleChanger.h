#pragma once

#include <QObject>
#include <QTranslator>
#include <QQmlEngine>

class LocaleChanger : public QObject {
    Q_OBJECT

public:
    LocaleChanger(QQmlEngine* engine, QString pathPrefix, QString filePrefix);

    Q_INVOKABLE
    void changeLocale(QString language);

private:
    QQmlEngine* engine;
    QString pathPrefix;
    QString filePrefix;
    QTranslator* translator;
};
