#include <QDebug>
#include <QGuiApplication>
#include <QDir>

#include "LocaleChanger.h"

/**
 * @brief LocaleChanger::LocaleChanger  Class that allows to configure the user interface language
 *   and all other elements of the locale, and to change them at runtime, triggered either from
 *   C++ or from QML. Follows the technique demonstrated in https://github.com/retifrav/translating-qml
 *   and described in blog post https://retifrav.github.io/blog/2017/01/04/translating-qml-app/ .
 *   Note that the code is not directly copied from there, so no licence issues arise. Anyway, the
 *   demo application is MIT licenced, and of course we want to give credit to it here :-)
 * @param engine  The application's QQmlEngine.
 * @param pathPrefix  The path to the directory inside the Qt resource system where the translation
 *   files are located. With a leading "/", without a trailing "/".
 * @param filePrefix  The prefix of the .qm files containing the translations. Everything before
 *   the language code and ".qm" file extension.
 * @todo Allow this class to listen and react to QEvent::LocaleChange events, to allow changing the
 *   locale without restarting the application when the OS tells to do so. The event filtering
 *   technique shown here should work for this purpose: https://forum.qt.io/post/276252
 */
LocaleChanger::LocaleChanger(QQmlEngine* engine, QString pathPrefix, QString filePrefix) {
    this->engine = engine;
    this->pathPrefix = pathPrefix;
    this->filePrefix = filePrefix;
    this->translator = new QTranslator(this);
}


/**
 * @brief LanguageSwitcher::selectLanguage  Switch the user interface language of the application
 *   to the specified language.
 * @param language  A two-letter language code, such as "en", "de".
 * @todo Make this a more independent class by not hardcoding the path template.
 */
void LocaleChanger::changeLanguage(QString language) {

    // TODO: Fix that the file is not found when using the qrc:/ or qrc:/// prefix, even though it
    // should be completely synonymous.
    const QString translationFile(QString(":%1/%2%3.qm").arg(pathPrefix).arg(filePrefix).arg(language));

    // Chaning the language works also without removing the old translator first, since the new
    // translation file is loaded into the old translator below. But the wiki example removes it first:
    // https://wiki.qt.io/How_to_create_a_multi_language_application#Switching_the_language
    qApp->removeTranslator(translator);

    if (!translator->load(translationFile))
        qWarning() << "Failed to load translation file" << translationFile << ". Falling back to English.";

    // Note: installTranslator() emits a QEvent::LanguageChange event, which may be handled by other
    // components of the application that also need to react to language changes, such as topic language.
    qApp->installTranslator(translator); // qApp is a global variable made available by QGuiApplication

    // TODO It seems cleaner to instead send a QEvent::LanguageChange event to engine, as documented here:
    // https://doc.qt.io/qt-5/qtquick-internationalization.html#9-prepare-for-dynamic-language-changes .
    // That can be done by implementing an event filter for this event when it is emitted by
    // installTranslator() above, as per https://forum.qt.io/post/276252 . Maybe the engine then passes
    // it to other QML components, allowing them to react as well.
    engine->retranslate();  // Render the QML UI with translations in the new language.
}
