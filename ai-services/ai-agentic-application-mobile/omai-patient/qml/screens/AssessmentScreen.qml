import QtQuick
import Omai
OmaiPage {
    OmaiStatusBadge { text: "RELATO DO PACIENTE · NÃO É DIAGNÓSTICO" }
    OmaiText { text: "Um próximo passo,\ncom mais clareza."; size: 28; font.weight: Font.DemiBold; width: parent.width }
    OmaiText { text: "Compartilhe estas informações com um profissional de saúde."; color: Theme.muted; width: parent.width }
    Repeater {
        model: [{title:"Sintomas",subtitle:patient.state.symptom || "Nenhum sintoma informado",icon:"heart"},{title:"Localização e duração",subtitle:(patient.state.location || "A confirmar") + " · " + (patient.state.duration || "A confirmar"),icon:"clock"},{title:"Intensidade relatada",subtitle:patient.state.step >= 3 ? patient.state.intensity + " de 10" : "Não informada",icon:"sliders"},{title:"Histórico relacionado",subtitle:"Hipertensão · Registro profissional demonstrativo",icon:"document"},{title:"Medicamentos relacionados",subtitle:"Losartana 50 mg · Registro demonstrativo",icon:"pill"},{title:"Observações",subtitle: patient.state.urgent ? "Sinal de alerta relatado. Procure atendimento médico imediato." : "Resumo de um roteiro simulado. Requer avaliação humana.",icon:"shield"}]
        OmaiHealthCard { required property var modelData; width: parent.width; record: modelData }
    }
    OmaiButton { width: parent.width; text: "Agendar consulta"; onClicked: patient.act("book") }
    OmaiButton { width: parent.width; text: patient.state.saved ? "✓ Salvo no histórico" : "Salvar no histórico"; secondary: true; enabled: !patient.state.saved && patient.state.step > 0; onClicked: patient.act("save") }
    OmaiButton { width: parent.width; text: "Falar com médico"; secondary: true; onClicked: patient.navigate("consultations") }
    OmaiButton { width: parent.width; text: "Continuar conversando"; secondary: true; onClicked: patient.navigate("chat") }
}
