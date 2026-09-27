#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QTimer>
#include <QDir>
#include <QFile>
#include "presentation/viewmodels/PatientViewModel.h"
int main(int argc, char *argv[]) {
    qInstallMessageHandler([](QtMsgType type, const QMessageLogContext &, const QString &message) {
        QFile log("build/runtime.log");
        if (log.open(QIODevice::Append)) log.write(message.toUtf8() + '\n');
        if (type == QtFatalMsg) abort();
    });
    QGuiApplication app(argc, argv);
    app.setApplicationName("OMAI Patient");
    app.setOrganizationName("OMAI");
    QQuickStyle::setStyle("Basic");
    PatientViewModel patient;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("patient", &patient);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.loadFromModule("Omai", "Main");
    if (app.arguments().contains("--smoke")) {
        const bool compact = app.arguments().contains("--compact");
        const QString captureDirectory = compact ? "build/screenshots-compact" : "build/screenshots";
        if (compact && !engine.rootObjects().isEmpty()) {
            auto window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
            window->resize(360, 800);
            auto theme = engine.singletonInstance<QObject *>("Omai", "Theme");
            theme->setProperty("fontScale", 1.3);
        }
        auto routes = QStringList{"splash", "onboarding", "login", "home", "chat", "assessment", "consultations", "consultation", "video", "history", "clinical", "exams", "exam", "medications", "prescriptions", "prescription", "verification", "documents", "privacy", "audit", "security", "profile", "preferences", "notifications", "devices", "personal", "help", "urgent", "original", "clinical-visit", "cancelled-visit", "procedure", "certificate", "report", "referral", "used-prescription", "expired-prescription", "revoked-prescription", "professional-access", "home", "profile", "chat"};
        QDir().mkpath(captureDirectory);
        auto timer = new QTimer(&app);
        QObject::connect(timer, &QTimer::timeout, &app, [&, timer, routes, captureDirectory, index = 0]() mutable {
            if (index > 0 && !engine.rootObjects().isEmpty()) {
                auto window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
                const QString file = captureDirectory + QString("/%1-%2.bmp").arg(index - 1, 2, 10, QChar('0')).arg(routes[index - 1]);
                if (!window || !window->grabWindow().save(file)) qFatal("Failed to capture smoke screenshot");
            }
            if (index >= routes.size()) { timer->stop(); app.exit(0); return; }
            if (index == 3) patient.act("demo-login");
            if (index == 5) { patient.send("Dor de cabeça há 3 dias"); patient.send("Frontal"); patient.send("6/10"); patient.send("Não percebi esses sinais"); patient.act("save"); }
            if (index == 39) patient.setDark(true);
            patient.navigate(routes[index++]);
        });
        timer->start(450);
    }
    return app.exec();
}
