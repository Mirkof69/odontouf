import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/consulta_model.dart';

class ConsultasController {
  static const String _baseUrl =
      'https://odontobd-ec688-default-rtdb.firebaseio.com/Consultas';

  Future<List<Consulta>> getConsultas() async {
    final response = await http.get(Uri.parse('$_baseUrl.json'));
    if (response.statusCode != 200) return [];
    final Map<String, dynamic>? data = json.decode(response.body);
    if (data == null) return [];
    final consultas = <Consulta>[];
    for (final entry in data.entries) {
      final consulta = Consulta.fromMap(Map<String, dynamic>.from(entry.value));
      consultas.add(consulta);
    }
    return consultas;
  }

  Future<void> agregarConsulta(Consulta consulta) async {
    await http.put(
      Uri.parse('$_baseUrl/${consulta.idConsulta}.json'),
      body: json.encode(consulta.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> editarConsulta(Consulta consulta) async {
    await http.patch(
      Uri.parse('$_baseUrl/${consulta.idConsulta}.json'),
      body: json.encode(consulta.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<List<Consulta>> buscarConsultas(String query) async {
    final consultas = await getConsultas();
    final q = query.toLowerCase();
    return consultas
        .where(
          (c) =>
              c.motivoConsulta.toLowerCase().contains(q) ||
              c.estadoConsulta.toLowerCase().contains(q) ||
              c.historiaClinicaId.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<String> getNextIdConsulta() async {
    final consultas = await getConsultas();
    if (consultas.isEmpty) return '1';
    final maxNum = consultas
        .map((c) => c.idConsulta)
        .fold<int>(0, (prev, curr) => curr > prev ? curr : prev);
    return (maxNum + 1).toString();
  }
}
