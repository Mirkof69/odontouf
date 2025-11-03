import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/paciente_model.dart';

class PacientesController {
  static const String _baseUrl =
      'https://odontobd-ec688-default-rtdb.firebaseio.com/Pacientes';

  Future<List<Paciente>> getPacientes({bool incluirInactivos = false}) async {
    final response = await http.get(Uri.parse('$_baseUrl.json'));
    if (response.statusCode != 200) return [];
    final Map<String, dynamic>? data = json.decode(response.body);
    if (data == null) return [];
    final pacientes = <Paciente>[];
    for (final entry in data.entries) {
      final paciente = Paciente.fromMap(Map<String, dynamic>.from(entry.value));
      if (incluirInactivos || paciente.activo) {
        pacientes.add(paciente);
      }
    }
    return pacientes;
  }

  Future<void> agregarPaciente(Paciente paciente) async {
    await http.put(
      Uri.parse('$_baseUrl/${paciente.idPaciente}.json'),
      body: json.encode(paciente.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> editarPaciente(Paciente paciente) async {
    await http.patch(
      Uri.parse('$_baseUrl/${paciente.idPaciente}.json'),
      body: json.encode(paciente.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> eliminarLogicoPaciente(int idPaciente) async {
    await http.patch(
      Uri.parse('$_baseUrl/$idPaciente.json'),
      body: json.encode({'activo': false}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> reactivarPaciente(int idPaciente) async {
    await http.patch(
      Uri.parse('$_baseUrl/$idPaciente.json'),
      body: json.encode({'activo': true}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<List<Paciente>> buscarPacientes(String query) async {
    final pacientes = await getPacientes(incluirInactivos: true);
    final q = query.toLowerCase();
    return pacientes
        .where(
          (p) =>
              p.nombres.toLowerCase().contains(q) ||
              p.apellidos.toLowerCase().contains(q) ||
              p.ci.toLowerCase().contains(q) ||
              p.numeroHistoriaClinica.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<String> getNextNumeroHistoriaClinica() async {
    final pacientes = await getPacientes(incluirInactivos: true);
    if (pacientes.isEmpty) return '1';
    final maxNum = pacientes
        .map((p) => int.tryParse(p.numeroHistoriaClinica) ?? 0)
        .fold<int>(0, (prev, curr) => curr > prev ? curr : prev);
    return (maxNum + 1).toString();
  }
}
