import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/consulta_model.dart';

class ConsultasControllerMobile {
  static const String _baseUrl =
      'https://odontobd-ec688-default-rtdb.firebaseio.com/Consultas';

  Future<List<Consulta>> getConsultas() async {
    final response = await http.get(Uri.parse('$_baseUrl.json'));
    if (response.statusCode != 200) return [];
    final dynamic data = json.decode(response.body);
    if (data == null) return [];
    final consultas = <Consulta>[];

    if (data is Map<String, dynamic>) {
      for (final entry in data.entries) {
        final map = Map<String, dynamic>.from(entry.value ?? {});
        if (map['id_consulta'] == null || map['id_consulta'] == 0) {
          final keyInt = int.tryParse(entry.key);
          if (keyInt != null) map['id_consulta'] = keyInt;
        }
        consultas.add(Consulta.fromMap(map));
      }
      return consultas;
    }

    if (data is List) {
      for (var i = 0; i < data.length; i++) {
        final item = data[i];
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          if (map['id_consulta'] == null || map['id_consulta'] == 0) {
            map['id_consulta'] = i + 1;
          }
          consultas.add(Consulta.fromMap(map));
        }
      }
      return consultas;
    }

    return [];
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
    int max = 0;
    for (final c in consultas) {
      if (c.idConsulta > max) max = c.idConsulta;
    }
    return (max + 1).toString();
  }
}
