class Consulta {
  final int idConsulta;
  final String historiaClinicaId;
  final String estudianteId;
  final String docenteValidadorId;
  final DateTime fechaConsulta;
  final String motivoConsulta;
  final String historiaEnfermedadActual;
  final String
  estadoConsulta; // "En Progreso", "Pendiente Validación", "Aprobada"

  Consulta({
    required this.idConsulta,
    required this.historiaClinicaId,
    required this.estudianteId,
    required this.docenteValidadorId,
    required this.fechaConsulta,
    required this.motivoConsulta,
    required this.historiaEnfermedadActual,
    required this.estadoConsulta,
  });

  factory Consulta.fromMap(Map<String, dynamic> map) {
    return Consulta(
      idConsulta: map['id_consulta'] ?? 0,
      historiaClinicaId: map['historia_clinica_id'] ?? '',
      estudianteId: map['estudiante_id'] ?? '',
      docenteValidadorId: map['docente_validador_id'] ?? '',
      fechaConsulta: map['fecha_consulta'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['fecha_consulta'])
          : DateTime.now(),
      motivoConsulta: map['motivo_consulta'] ?? '',
      historiaEnfermedadActual: map['historia_enfermedad_actual'] ?? '',
      estadoConsulta: map['estado_consulta'] ?? 'En Progreso',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_consulta': idConsulta,
      'historia_clinica_id': historiaClinicaId,
      'estudiante_id': estudianteId,
      'docente_validador_id': docenteValidadorId,
      'fecha_consulta': fechaConsulta.millisecondsSinceEpoch,
      'motivo_consulta': motivoConsulta,
      'historia_enfermedad_actual': historiaEnfermedadActual,
      'estado_consulta': estadoConsulta,
    };
  }
}
