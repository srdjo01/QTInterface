#include "projectmanager.h"
#include <QFile>
#include <QUrl>

ProjectManager::ProjectManager(QObject *parent)
    : QObject(parent)
{
}

bool ProjectManager::saveToFile(const QString &fileUrl, const QString &jsonContent)
{
    QString path = QUrl(fileUrl).toLocalFile();
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return false;
    file.write(jsonContent.toUtf8());
    file.close();
    return true;
}

QString ProjectManager::loadFromFile(const QString &fileUrl)
{
    QString path = QUrl(fileUrl).toLocalFile();
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return "";
    QString content = QString::fromUtf8(file.readAll());
    file.close();
    return content;
}
