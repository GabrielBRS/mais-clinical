import QtQuick
import QtQuick.Layouts
import Omai
OmaiPage {
    OmaiStatusBadge { text: "RESULTADO DISPONÍVEL · EXEMPLO" }
    OmaiText { width: parent.width; text: "Um olhar sobre\na sua saúde."; size: 28; font.weight: Font.DemiBold }
    OmaiText { width: parent.width; text: patient.page.subtitle; color: Theme.muted }
    Repeater {
        model: [{name:"Hemoglobina",value:"14,8",unit:"g/dL",ref:"Referência de exemplo: 13,0 – 17,0",previous:"14,5 g/dL · 3 mai 2026",position:0.45},{name:"Leucócitos",value:"6.400",unit:"/µL",ref:"Referência de exemplo: 4.000 – 11.000",previous:"6.100 /µL · 3 mai 2026",position:0.35},{name:"Plaquetas",value:"245.000",unit:"/µL",ref:"Referência de exemplo: 150.000 – 450.000",previous:"238.000 /µL · 3 mai 2026",position:0.32}]
        OmaiCard { required property var modelData; width: parent.width; height: values.implicitHeight + 40
            Column { id: values; x: 20; y: 20; width: parent.width - 40; spacing: 12
                OmaiText { text: modelData.name; font.weight: Font.DemiBold }
                Row { spacing: 8; OmaiText { text: modelData.value; size: 30; font.weight: Font.DemiBold } OmaiText { text: modelData.unit; color: Theme.muted; topPadding: 16 } }
                Rectangle { width: parent.width; height: 6; radius: 3; color: Theme.tint; Rectangle { x: parent.width * modelData.position; y: -3; width: 12; height: 12; radius: 6; color: Theme.teal } }
                OmaiText { text: modelData.ref; size: 11; color: Theme.muted; width: parent.width }
                OmaiText { text: "Anterior: " + modelData.previous; size: 11; color: Theme.muted; width: parent.width }
            }
        }
    }
    OmaiText { width: parent.width; text: "Valores fictícios. Os intervalos dependem do laboratório e do contexto clínico. Converse com o profissional responsável."; size: 12; color: Theme.muted }
    OmaiButton { text: "Perguntar à OMAI sobre este exame"; width: parent.width; onClicked: patient.act("exam-chat") }
    OmaiButton { text: "Ver arquivo original"; width: parent.width; secondary: true; onClicked: patient.act("original") }
}
