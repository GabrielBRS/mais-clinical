#pragma once
#include <QString>
#include <QDateTime>
namespace omai {
enum class PrescriptionStatus { Valid, Used, Expired, Revoked };
struct Prescription {
    QString id;
    QString professionalId;
    QByteArray contentHash;
    QByteArray detachedSignature;
    QByteArray certificateChain;
    QDateTime issuedAt;
    QDateTime expiresAt;
    QByteArray timestampToken;
    PrescriptionStatus status = PrescriptionStatus::Valid;
};
struct VerificationResult {
    bool signatureValid = false;
    bool integrityValid = false;
    bool professionalIdentified = false;
    bool withinValidity = false;
    bool revoked = false;
    bool serverChecked = false;
    bool simulated = true;
    QString reason;
};
}
