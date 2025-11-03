class HistoriaClinica {
  final int idHistoriaClinica;
  final String pacienteId;
  final DateTime fechaApertura;
  final String estadoHistoria;

  HistoriaClinica({
    required this.idHistoriaClinica,
    required this.pacienteId,
    required this.fechaApertura,
    required this.estadoHistoria,
  });

  factory HistoriaClinica.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is int) {
        // Assume stored as milliseconds since epoch.
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is double) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      }
      if (value is String) {
        final numeric = int.tryParse(value);
        if (numeric != null) {
          return DateTime.fromMillisecondsSinceEpoch(numeric);
        }
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    String parsePacienteId(Map<String, dynamic> src) {
      final direct = src['paciente_id'] ?? src['pacienteId'];
      if (direct != null && direct.toString().trim().isNotEmpty) {
        return direct.toString().trim();
      }
      final paciente = src['paciente'];
      if (paciente is Map) {
        final candidate =
            paciente['id_paciente'] ?? paciente['idPaciente'] ?? paciente['id'];
        if (candidate != null) {
          return candidate.toString().trim();
        }
      }
      return '';
    }

    String parseEstado(Map<String, dynamic> src) {
      final estado =
          src['estado_historia'] ?? src['estadoHistoria'] ?? src['estado'];
      if (estado == null) return 'Activa';
      final value = estado.toString().trim();
      return value.isEmpty ? 'Activa' : value;
    }

    final id = parseInt(
      map['id_historia_clinica'] ?? map['idHistoriaClinica'] ?? map['id'],
    );
    final pacienteId = parsePacienteId(map);
    final fecha = parseDate(
      map['fecha_apertura'] ?? map['fechaApertura'] ?? map['fecha'],
    );
    final estado = parseEstado(map);

    return HistoriaClinica(
      idHistoriaClinica: id,
      pacienteId: pacienteId,
      fechaApertura: fecha,
      estadoHistoria: estado,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_historia_clinica': idHistoriaClinica,
      'paciente_id': pacienteId,
      'fecha_apertura': fechaApertura.millisecondsSinceEpoch,
      'estado_historia': estadoHistoria,
    };
  }
}
