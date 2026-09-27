#pragma once
#include <QFuture>
#include "domain/prescription/Prescription.h"
namespace omai {
class PrescriptionVerifier {
public:
    virtual ~PrescriptionVerifier() = default;
    // Production must verify certificate trust, signature, canonical content hash,
    // trusted timestamp, expiry and online revocation. Encryption alone is insufficient.
    virtual QFuture<VerificationResult> verify(const Prescription &) = 0;
};
}
