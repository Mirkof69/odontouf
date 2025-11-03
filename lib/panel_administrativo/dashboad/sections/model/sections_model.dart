class Section {
  final String name;
  final List<String> subSections;
  bool expanded;
  Section({
    required this.name,
    required this.subSections,
    this.expanded = false,
  });
}

class SectionsModel {
  final List<Section> sections = [
    Section(name: 'Central', subSections: ['Pacientes', 'Usuarios']),
    Section(
      name: 'ANAMNESIS_GENERAL',
      subSections: [
        'Anamnesis_Familiares',
        'Anamnesis_Ginecologicos',
        'Anamnesis_NoPatologicos',
        'Anamnesis_Personales',
      ],
    ),
    Section(name: 'EXAMEN CLÍNICO', subSections: ['Examen_Estomatologico']),
    Section(
      name: 'FICHAS DE ESPECIALIDAD',
      subSections: [
        'Ficha_Endodoncia',
        'Ficha_Odontopediatria',
        'Ficha_Prostodoncia',
      ],
    ),
    Section(
      name: 'Gestion_Clinica',
      subSections: ['Consultas', 'Historias_clinicas'],
    ),
    Section(
      name: 'PROTOCOLO QUIRÚRGICO',
      subSections: ['Protocolo_Quirurgico'],
    ),
    Section(name: 'SEGUIMIENTO DE TRATAMIENTO', subSections: ['Seguimientos']),
    Section(name: 'SIGNOS VITALES', subSections: ['Examen_Fisico']),
  ];
}
