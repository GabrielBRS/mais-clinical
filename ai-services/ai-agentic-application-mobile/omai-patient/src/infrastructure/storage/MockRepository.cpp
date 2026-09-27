#include "MockRepository.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
QVariantMap omai::MockRepository::load() {
    QFile file(":/qt/qml/Omai/assets/mock.json");
    if (!file.open(QIODevice::ReadOnly)) qFatal("Cannot load demonstration records");
    QJsonParseError error;
    auto document = QJsonDocument::fromJson(file.readAll(), &error);
    if (error.error != QJsonParseError::NoError) qFatal("Invalid demonstration records");
    return document.object().toVariantMap();
}
