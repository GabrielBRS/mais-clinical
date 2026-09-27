#include "PatientViewModel.h"
#include "infrastructure/storage/MockRepository.h"
#include <QTimer>
#include <QRegularExpression>

PatientViewModel::PatientViewModel(QObject *parent) : QObject(parent), m_data(omai::MockRepository::load()) {
    appendMessage("assistant", "Olá, Gabriel. Sou a OMAI, sua assistente de saúde. Posso organizar seus sintomas e ajudar você a se preparar para uma consulta. Como você está se sentindo?");
}
QVariantMap PatientViewModel::page() const { return m_data.value(m_screen).toMap(); }
void PatientViewModel::setDark(bool value) { m_dark = value; emit changed(); }
void PatientViewModel::navigate(const QString &target) {
    if (!m_data.contains(target)) { notify("Esta área ainda não está disponível."); return; }
    if (!m_signedIn && target != "splash" && target != "onboarding" && target != "login") return;
    if (target == m_screen) return;
    m_stack.append(m_screen);
    m_screen = target; m_filter.clear(); emit changed();
}
void PatientViewModel::back() {
    if (m_stack.isEmpty()) return;
    m_screen = m_stack.takeLast(); m_filter.clear(); emit changed();
}
void PatientViewModel::login(const QString &email, const QString &password, bool signup) {
    static QRegularExpression validEmail("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    if (!validEmail.match(email.trimmed()).hasMatch() || password.size() < 6) {
        notify("Informe um e-mail válido e uma senha de pelo menos 6 caracteres."); return;
    }
    m_signedIn = true; navigate("home"); m_stack.clear();
    notify(signup ? "Conta demonstrativa criada. Nenhum dado foi enviado." : "Bem-vindo. Você está em uma sessão demonstrativa.");
}
void PatientViewModel::notify(const QString &message) {
    m_toast = message; emit changed();
    QTimer::singleShot(4500, this, [this, message] { if (m_toast == message) { m_toast.clear(); emit changed(); } });
}
void PatientViewModel::appendMessage(const QString &role, const QString &text) {
    m_messages.append(QVariantMap{{"role", role}, {"text", text}});
}
QStringList PatientViewModel::suggestions() const {
    if (m_report.alertReported) return {"Encontrar atendimento"};
    switch (m_step) {
    case 0: return {"Dor de cabeça há 3 dias", "Preparar uma consulta", "Sobre meu exame"};
    case 1: return {"Frontal", "Atrás dos olhos", "Um lado da cabeça", "Cabeça inteira"};
    case 2: return {"Leve · 3/10", "Moderada · 6/10", "Forte · 9/10"};
    case 3: return {"Não percebi esses sinais", "Sim, tenho um sinal de alerta"};
    default: return {"Ver resumo da avaliação", "Falar com médico"};
    }
}
void PatientViewModel::send(const QString &raw) {
    const auto text = raw.trimmed().left(2000);
    if (text.isEmpty()) return;
    if (text == "Ver resumo da avaliação") { navigate("assessment"); return; }
    if (text == "Falar com médico" || text == "Encontrar atendimento") { navigate(text == "Encontrar atendimento" ? "urgent" : "consultations"); return; }
    appendMessage("user", text);
    const auto lower = text.toLower();
    if (lower.contains("sinal de alerta") || lower.contains("falta de ar") || lower.contains("dor no peito") || lower.contains("desmaio")) {
        m_report.alertReported = true;
        appendMessage("assistant", "Procure atendimento médico imediato. Esta demonstração não avalia gravidade e não substitui atendimento profissional.");
    } else if (m_step == 0 && (lower.contains("exame") || lower.contains("consulta"))) {
        appendMessage("assistant", "Posso reunir suas informações para conversar com um profissional. Na demonstração, não interpreto resultados nem emito diagnósticos. Você pode acessar os exames e consultas pelo seu histórico.");
    } else {
        switch (m_step) {
        case 0:
            m_report.description = text; m_report.duration = lower.contains("3 dias") || lower.contains("três dias") ? "3 dias" : "A confirmar com o paciente";
            appendMessage("assistant", "Vou fazer algumas perguntas para organizar seu relato. Neste roteiro demonstrativo de dor de cabeça, onde a dor está localizada?"); break;
        case 1:
            m_report.location = text;
            appendMessage("assistant", "Entendi. Em uma escala de 0 a 10, qual é a intensidade da dor agora?"); break;
        case 2: {
            auto match = QRegularExpression("(10|[0-9])").match(text);
            if (!match.hasMatch()) { appendMessage("assistant", "Escolha uma intensidade de 0 a 10 para continuar."); emit changed(); return; }
            m_report.intensity = match.captured(1).toInt();
            appendMessage("assistant", "Há algum sinal de alerta, como dificuldade para respirar, desmaio, alteração de fala ou dor súbita muito intensa? Este roteiro não cobre todas as situações de urgência."); break;
        }
        default:
            appendMessage("assistant", "Organizei seu relato. O resumo está pronto para ser compartilhado em uma consulta. Apenas um profissional pode avaliar seus sintomas e indicar uma conduta."); break;
        }
        ++m_step;
    }
    emit changed();
}
void PatientViewModel::setFilter(const QString &filter) { m_filter = filter; emit changed(); }
QVariantMap PatientViewModel::state() const {
    return {{"saved", m_saved}, {"taken", m_taken}, {"reminders", m_reminders}, {"revoked", m_revoked}, {"professionalRevoked", m_professionalRevoked},
        {"cancelled", m_cancelled}, {"rescheduled", m_rescheduled}, {"mic", m_mic}, {"camera", m_camera}, {"speaker", m_speaker},
        {"step", m_step}, {"urgent", m_report.alertReported}, {"symptom", m_report.description},
        {"location", m_report.location}, {"duration", m_report.duration}, {"intensity", m_report.intensity},
        {"verification", m_verification}, {"verificationReason", m_verificationReason}};
}
QVariantList PatientViewModel::cards() const {
    auto result = page().value("cards").toList();
    if (m_screen == "history" && m_saved) result.prepend(QVariantMap{{"title", "Avaliação OMAI"}, {"subtitle", "Hoje · Relato organizado pelo paciente"}, {"icon", "spark"}, {"category", "Avaliações"}, {"route", "assessment"}, {"badge", "Salvo"}});
    if (m_screen == "audit" && m_revoked) result.prepend(QVariantMap{{"title", "Você revogou um acesso"}, {"subtitle", "Agora · Clínica OMAI · Todos os dados"}, {"icon", "shield"}, {"badge", "Revogado"}});
    if (m_screen == "audit" && m_professionalRevoked) result.prepend(QVariantMap{{"title", "Você revogou um acesso"}, {"subtitle", "Agora · Dr. João Silva · Histórico, exames e prescrições"}, {"icon", "shield"}, {"badge", "Revogado"}});
    QVariantList filtered;
    for (auto entry : result) {
        auto card = entry.toMap();
        if (m_screen == "privacy" && card.value("route") == "professional-access") card["badge"] = m_professionalRevoked ? "Revogado" : "Ativo";
        if (m_screen == "consultations" && card.value("id") == "next") {
            card["category"] = m_cancelled ? "Canceladas" : "Próximas";
            card["badge"] = m_cancelled ? "Cancelada" : "Confirmada";
            if (m_rescheduled) card["subtitle"] = "Cardiologia · 28 set, 10:00 · Teleconsulta";
        }
        if (m_screen == "privacy" && card.value("id") == "clinic") {
            card["badge"] = m_revoked ? "Revogado" : "Ativo";
            card["action"] = m_revoked ? "revoked" : "revoke-confirm";
        }
        if (!m_filter.isEmpty() && m_filter != "Todos" && card.value("category").toString() != m_filter) continue;
        filtered.append(card);
    }
    return filtered;
}
void PatientViewModel::verify(const QString &code, const QString &scenario) {
    m_verification = "loading"; m_verificationReason.clear(); emit changed();
    const int generation = ++m_verificationGeneration;
    QTimer::singleShot(1000, this, [this, code, scenario, generation] {
        if (generation != m_verificationGeneration) return;
        if (code.trimmed() != "OMAI-2026-00842") { m_verification = "invalid"; m_verificationReason = "Identificador não encontrado na base demonstrativa."; }
        else if (scenario != "Válida") { m_verification = "invalid"; m_verificationReason = scenario == "Expirada" ? "Documento expirado" : scenario == "Revogada" ? "Documento revogado" : "Assinatura inválida"; }
        else { m_verification = "valid"; m_verificationReason = "Cenário simulado. Nenhuma assinatura criptográfica foi verificada."; }
        emit changed();
    });
}
void PatientViewModel::act(const QString &action) {
    if (action == "demo-login") { m_signedIn = true; navigate("home"); m_stack.clear(); }
    else if (action == "logout") { m_signedIn = false; m_screen = "login"; m_stack.clear(); m_messages.clear(); m_report = {}; m_step = 0; appendMessage("assistant", "Olá, Gabriel. Como você está se sentindo? Esta conversa é demonstrativa."); }
    else if (action == "save") { m_saved = true; notify("Avaliação salva no histórico desta demonstração."); }
    else if (action == "dose") { m_taken = !m_taken; notify(m_taken ? "Dose registrada hoje às 08:00." : "Registro da dose desfeito."); }
    else if (action == "reminders") m_reminders = !m_reminders;
    else if (action == "revoke") { m_revoked = true; notify("Acesso da Clínica OMAI revogado nesta sessão."); }
    else if (action == "revoke-professional") { m_professionalRevoked = true; notify("Acesso do Dr. João Silva revogado nesta sessão."); }
    else if (action == "cancel") { m_cancelled = true; notify("Consulta cancelada. Veja a aba Canceladas."); navigate("consultations"); }
    else if (action == "reschedule") { m_rescheduled = true; m_cancelled = false; notify("Consulta reagendada para 28 de setembro, às 10:00."); }
    else if (action == "book") { m_cancelled = false; navigate("consultation"); notify("Consulta demonstrativa confirmada."); }
    else if (action == "mic") m_mic = !m_mic;
    else if (action == "camera") m_camera = !m_camera;
    else if (action == "speaker") m_speaker = !m_speaker;
    else if (action == "end-call") { navigate("prescriptions"); notify("Chamada demonstrativa encerrada. Prescrição disponível no cofre."); }
    else if (action == "exam-chat") { navigate("chat"); appendMessage("assistant", "Contexto anexado: Hemograma completo · 12 ago 2026. Os valores são fictícios. Posso organizar suas dúvidas para o profissional responsável."); }
    else if (action == "attach") { appendMessage("user", "📎 Hemograma completo · PDF demonstrativo"); notify("Exame de exemplo anexado à conversa."); }
    else if (action == "revoked") notify("Este acesso já foi revogado.");
    else if (action == "biometry" || action == "passkey" || action == "2fa") notify("Disponível após integração com o sistema e o serviço de autenticação. Nenhuma proteção real foi ativada.");
    else if (action == "voice") notify("Entrada por voz e imagens prevista para uma próxima versão.");
    else if (action == "original") navigate("original");
    else if (action == "restart") { m_messages.clear(); m_report = {}; m_step = 0; appendMessage("assistant", "Olá, Gabriel. Vamos organizar seu relato. Como você está se sentindo?"); }
    else notify("Preferência demonstrativa atualizada nesta sessão.");
    emit changed();
}
