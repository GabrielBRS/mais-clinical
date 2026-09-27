#pragma once
#include <QString>
#include <QFuture>
#include "domain/patient/HealthRecord.h"
namespace omai {
enum class ComputeBackend { Cloud, Cpu, Gpu, Npu };
struct AIModel { QString id; QString provider; ComputeBackend backend; };
struct AIResponse { QString message; SymptomReport report; bool referToHuman = true; };
class AIInferenceEngine {
public:
    virtual ~AIInferenceEngine() = default;
    virtual QFuture<AIResponse> infer(const SymptomReport &report) = 0;
    virtual bool available() const = 0;
};
// Platform adapters implement these contracts; no model/provider is hardcoded.
class RemoteInferenceEngine : public AIInferenceEngine {};
class LocalInferenceEngine : public AIInferenceEngine {};
}
