class Paciente {
  final int idPaciente;
  final String numeroHistoriaClinica;
  final String nombres;
  final String apellidos;
  final String ci;
  final DateTime fechaNacimiento;
  final String sexo;
  final String estadoCivil;
  final String ocupacion;
  final String direccion;
  final String celular;
  final String telefono;
  final String contactoEmergenciaNombre;
  final String contactoEmergenciaTelefono;
  final DateTime fechaRegistro;
  bool activo;

  Paciente({
    required this.idPaciente,
    required this.numeroHistoriaClinica,
    required this.nombres,
    required this.apellidos,
    required this.ci,
    required this.fechaNacimiento,
    required this.sexo,
    required this.estadoCivil,
    required this.ocupacion,
    required this.direccion,
    required this.celular,
    required this.telefono,
    required this.contactoEmergenciaNombre,
    required this.contactoEmergenciaTelefono,
    required this.fechaRegistro,
    this.activo = true,
  });

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      idPaciente: map['id_paciente'] ?? 0,
      numeroHistoriaClinica: map['numero_historia_clinica'] ?? '',
      nombres: map['nombres'] ?? '',
      apellidos: map['apellidos'] ?? '',
      ci: map['ci'] ?? '',
      fechaNacimiento:
          DateTime.tryParse(map['fecha_nacimiento'] ?? '') ?? DateTime(2000),
      sexo: map['sexo'] ?? '',
      estadoCivil: map['estado_civil'] ?? '',
      ocupacion: map['ocupacion'] ?? '',
      direccion: map['direccion'] ?? '',
      celular: map['celular'] ?? '',
      telefono: map['telefono'] ?? '',
      contactoEmergenciaNombre: map['contacto_emergencia_nombre'] ?? '',
      contactoEmergenciaTelefono: map['contacto_emergencia_telefono'] ?? '',
      fechaRegistro: map['fecha_registro'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['fecha_registro'])
          : DateTime.now(),
      activo: map['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_paciente': idPaciente,
      'numero_historia_clinica': numeroHistoriaClinica,
      'nombres': nombres,
      'apellidos': apellidos,
      'ci': ci,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'sexo': sexo,
      'estado_civil': estadoCivil,
      'ocupacion': ocupacion,
      'direccion': direccion,
      'celular': celular,
      'telefono': telefono,
      'contacto_emergencia_nombre': contactoEmergenciaNombre,
      'contacto_emergencia_telefono': contactoEmergenciaTelefono,
      'fecha_registro': fechaRegistro.millisecondsSinceEpoch,
      'activo': activo,
    };
  }
}
