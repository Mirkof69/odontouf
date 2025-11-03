class Usuario {
  final int idUsuario;
  final String nombreCompleto;
  final String ci;
  final String email;
  final String nombreUsuario;
  final String contrasenaHash;
  final String rol; // "Administrativo", "Docente", "Estudiante"
  final int? semestre; // Solo si es estudiante
  final String? especialidadDocente; // Solo si es docente
  final String estado; // "Activo", "Inactivo"

  Usuario({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.ci,
    required this.email,
    required this.nombreUsuario,
    required this.contrasenaHash,
    required this.rol,
    this.semestre,
    this.especialidadDocente,
    required this.estado,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['id_usuario'] ?? 0,
      nombreCompleto: map['nombre_completo'] ?? '',
      ci: map['ci'] ?? '',
      email: map['email'] ?? '',
      nombreUsuario: map['nombre_usuario'] ?? '',
      contrasenaHash: map['contrasena_hash'] ?? '',
      rol: map['rol'] ?? '',
      semestre: map['semestre'],
      especialidadDocente: map['especialidad_docente'],
      estado: map['estado'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_usuario': idUsuario,
      'nombre_completo': nombreCompleto,
      'ci': ci,
      'email': email,
      'nombre_usuario': nombreUsuario,
      'contrasena_hash': contrasenaHash,
      'rol': rol,
      if (semestre != null) 'semestre': semestre,
      if (especialidadDocente != null)
        'especialidad_docente': especialidadDocente,
      'estado': estado,
    };
  }

  Usuario copyWith({
    int? idUsuario,
    String? nombreCompleto,
    String? ci,
    String? email,
    String? nombreUsuario,
    String? contrasenaHash,
    String? rol,
    int? semestre,
    String? especialidadDocente,
    String? estado,
  }) {
    return Usuario(
      idUsuario: idUsuario ?? this.idUsuario,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      ci: ci ?? this.ci,
      email: email ?? this.email,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      contrasenaHash: contrasenaHash ?? this.contrasenaHash,
      rol: rol ?? this.rol,
      semestre: semestre ?? this.semestre,
      especialidadDocente: especialidadDocente ?? this.especialidadDocente,
      estado: estado ?? this.estado,
    );
  }
}
