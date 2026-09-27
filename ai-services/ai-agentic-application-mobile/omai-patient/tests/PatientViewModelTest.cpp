#include <QtTest>
#include "presentation/viewmodels/PatientViewModel.h"
class PatientViewModelTest : public QObject {
    Q_OBJECT
private slots:
    void authenticationAndNavigation() {
        PatientViewModel vm;
        vm.navigate("home"); QCOMPARE(vm.screen(), "splash");
        vm.navigate("onboarding"); vm.navigate("login");
        vm.login("bad", "x"); QCOMPARE(vm.screen(), "login");
        vm.login("demo@example.com", "abcdef"); QCOMPARE(vm.screen(), "home");
        vm.navigate("exams"); vm.back(); QCOMPARE(vm.screen(), "home");
        vm.act("logout"); vm.navigate("prescription"); QCOMPARE(vm.screen(), "login");
    }
    void assessmentAndHistory() {
        PatientViewModel vm; vm.act("demo-login"); vm.navigate("chat");
        vm.send("Dor de cabeça há 3 dias"); vm.send("Frontal"); vm.send("6/10"); vm.send("Não percebi esses sinais");
        QCOMPARE(vm.state()["step"].toInt(), 4); QVERIFY(!vm.state()["urgent"].toBool());
        vm.act("save"); vm.navigate("history"); QCOMPARE(vm.cards().first().toMap()["title"].toString(), "Avaliação OMAI");
        vm.setFilter("Exames"); QCOMPARE(vm.cards().size(), 1);
    }
    void urgencyAndDose() {
        PatientViewModel vm; vm.send("Estou com falta de ar"); QVERIFY(vm.state()["urgent"].toBool());
        vm.act("dose"); QVERIFY(vm.state()["taken"].toBool()); vm.act("dose"); QVERIFY(!vm.state()["taken"].toBool());
    }
    void consultationAndPrivacy() {
        PatientViewModel vm; vm.act("demo-login"); vm.act("cancel"); vm.setFilter("Canceladas"); QCOMPARE(vm.cards().size(), 2);
        vm.act("reschedule"); QVERIFY(!vm.state()["cancelled"].toBool());
        vm.act("revoke"); vm.navigate("audit"); QCOMPARE(vm.cards().first().toMap()["badge"].toString(), "Revogado");
    }
    void verificationStates() {
        PatientViewModel vm;
        vm.verify("OMAI-2026-00842", "Válida"); QCOMPARE(vm.state()["verification"].toString(), "loading");
        QTRY_COMPARE(vm.state()["verification"].toString(), "valid");
        for (const auto &scenario : {"Expirada", "Revogada", "Assinatura inválida"}) {
            vm.verify("OMAI-2026-00842", scenario); QTRY_COMPARE(vm.state()["verification"].toString(), "invalid");
        }
        vm.verify("unknown", "Válida"); QTRY_COMPARE(vm.state()["verification"].toString(), "invalid");
    }
};
QTEST_GUILESS_MAIN(PatientViewModelTest)
#include "PatientViewModelTest.moc"
