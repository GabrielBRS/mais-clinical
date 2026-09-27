#pragma once
#include <QString>
#include <QDateTime>

namespace omai {
enum class RecordOrigin { Patient, Professional };
struct SymptomReport {
    QString description;
    QString location;
    QString duration;
    int intensity = 6;
    bool alertReported = false;
};
struct AccessGrant {
    QString id;
    QString grantee;
    QString scope;
    QDateTime expiresAt;
    bool revoked = false;
};
}
