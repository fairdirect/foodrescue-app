#pragma once

#include <QObject>

class History : public QObject {

    Q_OBJECT

    // TODO: Maybe introduce different signals backPossibleChanged and forwardPossibleChanged, as
    //   that means fewer signal calls in total. But it's simpler this way, and no performance issue.
    Q_PROPERTY(QStringList history MEMBER m_history      NOTIFY historyChanged)
    Q_PROPERTY(bool backPossible READ backPossible       NOTIFY historyChanged)
    Q_PROPERTY(bool forwardPossible READ forwardPossible NOTIFY historyChanged)

    QStringList m_history;
    int m_currentIndex;

public:
    explicit History (QString startItem, QObject* parent = 0);

    Q_INVOKABLE // Allows to invoke this method from QML.
    QString back();

    Q_INVOKABLE
    QString forward();

    Q_INVOKABLE
    bool backPossible();

    Q_INVOKABLE
    bool forwardPossible();

    Q_INVOKABLE
    void add(QString item);

    Q_INVOKABLE
    QString current();

signals:
    void historyChanged();
};
