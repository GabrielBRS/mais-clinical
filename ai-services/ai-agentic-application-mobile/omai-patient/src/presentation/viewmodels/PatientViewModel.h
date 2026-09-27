#pragma once
#include <QObject>
#include <QVariantList>
#include <QStringList>
#include "domain/patient/HealthRecord.h"
class PatientViewModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString screen READ screen NOTIFY changed)
    Q_PROPERTY(QVariantMap page READ page NOTIFY changed)
    Q_PROPERTY(QVariantList messages READ messages NOTIFY changed)
    Q_PROPERTY(QVariantList cards READ cards NOTIFY changed)
    Q_PROPERTY(QStringList suggestions READ suggestions NOTIFY changed)
    Q_PROPERTY(QVariantMap state READ state NOTIFY changed)
    Q_PROPERTY(QString filter READ filter NOTIFY changed)
    Q_PROPERTY(QString toast READ toast NOTIFY changed)
    Q_PROPERTY(bool dark READ dark WRITE setDark NOTIFY changed)
public:
    explicit PatientViewModel(QObject *parent = nullptr);
    QString screen() const { return m_screen; }
    QVariantMap page() const;
    QVariantList messages() const { return m_messages; }
    QVariantList cards() const;
    QStringList suggestions() const;
    QVariantMap state() const;
    QString filter() const { return m_filter; }
    QString toast() const { return m_toast; }
    bool dark() const { return m_dark; }
    void setDark(bool value);
    Q_INVOKABLE void navigate(const QString &screen);
    Q_INVOKABLE void back();
    Q_INVOKABLE void login(const QString &email, const QString &password, bool signup = false);
    Q_INVOKABLE void send(const QString &message);
    Q_INVOKABLE void act(const QString &action);
    Q_INVOKABLE void setFilter(const QString &filter);
    Q_INVOKABLE void verify(const QString &code, const QString &scenario);
    Q_INVOKABLE void notify(const QString &message);
signals:
    void changed();
private:
    void appendMessage(const QString &role, const QString &text);
    QVariantMap m_data;
    QString m_screen = "splash", m_filter, m_toast;
    QStringList m_stack;
    QVariantList m_messages;
    omai::SymptomReport m_report;
    int m_step = 0, m_verificationGeneration = 0;
    bool m_dark = false, m_signedIn = false, m_saved = false, m_taken = false;
    bool m_reminders = true, m_revoked = false, m_professionalRevoked = false, m_cancelled = false, m_rescheduled = false;
    bool m_mic = true, m_camera = true, m_speaker = true;
    QString m_verification = "idle", m_verificationReason;
};
