#ifndef PROJECTMANAGER_H
#define PROJECTMANAGER_H

#include <QObject>
#include <QQmlEngine>

class ProjectManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit ProjectManager(QObject *parent = nullptr);

    Q_INVOKABLE bool saveToFile(const QString &fileUrl, const QString &jsonContent);
    Q_INVOKABLE QString loadFromFile(const QString &fileUrl);
};

#endif // PROJECTMANAGER_H
