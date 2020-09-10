#include <QObject>
#include <QDebug>
#include "History.h"

/**
 * @brief Create a history object, starting with a single initial history item.
 * @param startItem  The item to use for the "start of history", usually equivalent to the
 *   identifier of a start screen or homepage or other page displayed before the first user action.
 * @param parent  TODO
 */
History::History (QString startItem, QObject* parent) : QObject(parent) {
    m_history << startItem;
    m_currentIndex = 0;
}

/** @brief Navigate backwards in the history and return the identifier of the new current item. */
QString History::back() {
    if (backPossible()) {
        m_currentIndex--;
        historyChanged();
    }
    else
        qWarning() << "History::back() called but not possible.";

    return m_history.at(m_currentIndex);
}

/** @brief Navigate forward in the history and return the identifier of the new current item. */
QString History::forward() {
    if (forwardPossible()) {
        m_currentIndex++;
        historyChanged();
    }
    else
        qWarning() << "History::forward() called but not possible.";

    return m_history.at(m_currentIndex);
}

/** @brief Determine if navigating backwards in the history is possible. */
bool History::backPossible() {
    qDebug() << "History::backPossible() called.";
    qDebug() << "Current history list is:" << m_history;
    qDebug() << "Current index is:" << m_currentIndex;

    if (m_history.size() == 0) {
        return false;
    }
    else {
        int lastIndex = m_history.size() - 1;
        return m_currentIndex <= lastIndex && m_currentIndex > 0;
    }
}

/** @brief Determine if navigating forward in the history is possible. */
bool History::forwardPossible() {
    qDebug() << "History::forwardPossible() called.";

    if (m_history.size() == 0) {
        return false;
    }
    else {
        int lastIndex = m_history.size() - 1;
        return m_currentIndex < lastIndex;
    }
}

/**
 * @brief Add the provided item to the history.
 * @details If the item to add is the empty string, it is ignored. If the item to add is identical
 *   to the history item at the current position, nothing is added, but history following the
 *   current position is deleted (if any). This behavior should be in this model-level class and not
 *   in the QML UI code, because it is part of what makes a "history" different from a simple string list.
 * @param searchTerm  The item to add to the history.
 */
void History::add(QString item) {
    qDebug() << "History::add() called, item =" << item;
    if (item == "") return;

    // Use erase(begin, end) with pointer arithmetic to erase all elements after the current.
    //   Forgetting a part of the history is just like undo/redo steps: all redo steps after the
    //   first action done while navigating the undo history are thrown away to avoid branching.
    //   See: https://doc.qt.io/archives/qt-4.8/qlist-iterator.html#operator-2b
    m_history.erase(m_history.begin() + m_currentIndex + 1, m_history.end());

    if (item != current()) {
        qDebug() << "History::add(): adding item";
        m_history << item;
        m_currentIndex = m_history.size() - 1;
    }
    historyChanged();
}

/**
 * @brief Determine the current history item.
 * @return The identifier string of the current history item.
 */
QString History::current() {
    qDebug() << "History::current() called."
        << "m_currentIndex =" << m_currentIndex
        << "m_history =" << m_history;

    return m_history.at(m_currentIndex);
}
