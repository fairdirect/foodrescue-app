#include <QFile>
#include <QFileInfo>
#include <QSysInfo>
#include <QStandardPaths>

#include <QDebug>
#include <QMetaProperty>
#include <vector>
#include <utility>
#include <algorithm>

#include <QtXml/QDomDocument>

#include "utilities.h"


/**
 * @brief Copies the specified Android asset to an ordinary file in a location accessible by this
 *   application. If a copy already exists, use that.
 * @param assetName Specifies an Android asset, using Qt's "asset:/folder/name.ext" scheme.
 * @return Absolute filename of the file containing the copy of the specified asset.
 */
QString androidAssetToFile(QString assetPath) {

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
 * @brief Print the names and values of all properties of the given QObject.
 * @param The object to inspect.
 * @author maxschlepzig
 * @license CC-BY-SA; sourced from https://stackoverflow.com/a/36518687
 */
void debugPrintQObject(QObject *o) {
  auto mo = o->metaObject();
  qDebug() << "## Properties of" << o << "##";

  do {
    qDebug() << "### Class" << mo->className() << "###";
    std::vector<std::pair<QString, QVariant> > v;
    v.reserve(mo->propertyCount() - mo->propertyOffset());

    for (int i = mo->propertyOffset(); i < mo->propertyCount(); ++i)
      v.emplace_back(mo->property(i).name(), mo->property(i).read(o));

    std::sort(v.begin(), v.end());

    for (auto &i : v)
      qDebug() << i.first << "=>" << i.second;

  } while ((mo = mo->superClass()));
}


/**
 * @brief Pretty-print XML by inserting line breaks and spaces.
 * @param The XML string to pretty-print.
 * @return The pretty-printed XML string.
 */
QString formatXml(QString xml) {
    QDomDocument dom;
    dom.setContent(xml);
    return dom.toString(2);
}
