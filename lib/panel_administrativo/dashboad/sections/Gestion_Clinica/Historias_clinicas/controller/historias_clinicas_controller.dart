import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/historia_clinica_model.dart';

class HistoriasClinicasController {
  static const String _rootUrl =
      'https://odontobd-ec688-default-rtdb.firebaseio.com';
  static const List<String> _candidatePaths = <String>[
    'HistoriasClinicas',
    'historiasClinicas',
    'historias_clinicas',
    'Historias_clinicas',
    'historiasClinica',
    'HistoriasClinica',
  ];

  static String? _resolvedPath;
  static Map<String, dynamic>? _cachedRaw;

  Future<List<HistoriaClinica>> getHistoriasClinicas() async {
    final raw = await _loadHistoriasRaw();
    if (raw.isEmpty) return <HistoriaClinica>[];
    final historias = <HistoriaClinica>[];
    raw.forEach((key, value) {
      if (value is! Map) return;
      final map = <String, dynamic>{};
      value.forEach((k, v) => map[k.toString()] = v);
      if (map['id_historia_clinica'] == null ||
          map['id_historia_clinica'] == 0 ||
          map['id_historia_clinica'].toString().isEmpty) {
        final parsedKey = int.tryParse(key);
        if (parsedKey != null) {
          map['id_historia_clinica'] = parsedKey;
        }
      }
      if (map['paciente_id'] != null) {
        map['paciente_id'] = map['paciente_id'].toString();
      }
      final historia = HistoriaClinica.fromMap(map);
      historias.add(historia);
    });
    return historias;
  }

  Future<void> agregarHistoriaClinica(HistoriaClinica historia) async {
    final path = await _resolvePath();
    await http.put(
      Uri.parse('$_rootUrl/$path/${historia.idHistoriaClinica}.json'),
      body: json.encode(historia.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
    _cachedRaw = null;
  }

  Future<void> editarHistoriaClinica(HistoriaClinica historia) async {
    final path = await _resolvePath();
    await http.patch(
      Uri.parse('$_rootUrl/$path/${historia.idHistoriaClinica}.json'),
      body: json.encode(historia.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
    _cachedRaw = null;
  }

  Future<void> archivarHistoriaClinica(int idHistoriaClinica) async {
    final path = await _resolvePath();
    await http.patch(
      Uri.parse('$_rootUrl/$path/$idHistoriaClinica.json'),
      body: json.encode({'estado_historia': 'Archivada'}),
      headers: {'Content-Type': 'application/json'},
    );
    _cachedRaw = null;
  }

  Future<void> darDeAltaHistoriaClinica(int idHistoriaClinica) async {
    final path = await _resolvePath();
    await http.patch(
      Uri.parse('$_rootUrl/$path/$idHistoriaClinica.json'),
      body: json.encode({'estado_historia': 'De Alta'}),
      headers: {'Content-Type': 'application/json'},
    );
    _cachedRaw = null;
  }

  Future<List<HistoriaClinica>> buscarHistoriasClinicas(String query) async {
    final historias = await getHistoriasClinicas();
    final q = query.toLowerCase();
    return historias
        .where(
          (h) =>
              h.pacienteId.toLowerCase().contains(q) ||
              h.estadoHistoria.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<String> getNextIdHistoriaClinica() async {
    final raw = await _loadHistoriasRaw();
    if (raw.isEmpty) {
      return '1';
    }
    int maxId = 0;
    raw.forEach((key, value) {
      var candidate = int.tryParse(key) ?? 0;
      if (value is Map && candidate == 0) {
        final map = <String, dynamic>{};
        value.forEach((k, v) => map[k.toString()] = v);
        final field = map['id_historia_clinica'] ?? map['idHistoriaClinica'];
        candidate = field is int
            ? field
            : int.tryParse(field?.toString() ?? '') ?? 0;
      }
      if (candidate > maxId) maxId = candidate;
    });
    return (maxId + 1).toString();
  }

  Future<Map<String, dynamic>> _loadHistoriasRaw() async {
    if (_cachedRaw != null) {
      final cached = _cachedRaw!;
      _cachedRaw = null;
      return cached;
    }
    final path = await _resolvePath();
    return _fetchFromPath(path);
  }

  Future<String> _resolvePath() async {
    if (_resolvedPath != null) return _resolvedPath!;
    for (final candidate in _candidatePaths) {
      final data = await _fetchFromPath(candidate);
      if (data.isNotEmpty) {
        _resolvedPath = candidate;
        _cachedRaw = data;
        return _resolvedPath!;
      }
    }
    final rootData = await _fetchRoot();
    if (rootData != null) {
      for (final entry in rootData.entries) {
        final key = entry.key.toString();
        if (!key.toLowerCase().contains('historia')) continue;
        final normalized = _normalize(entry.value);
        if (normalized.isNotEmpty) {
          _resolvedPath = key;
          _cachedRaw = normalized;
          return _resolvedPath!;
        }
      }
    }
    _resolvedPath = _candidatePaths.first;
    return _resolvedPath!;
  }

  Future<Map<String, dynamic>?> _fetchRoot() async {
    final response = await http.get(Uri.parse('$_rootUrl/.json'));
    if (response.statusCode != 200) return null;
    final body = response.body.trim();
    if (body.isEmpty || body == 'null') return null;
    final dynamic decoded = json.decode(body);
    if (decoded is! Map) return null;
    return _normalize(decoded);
  }

  Future<Map<String, dynamic>> _fetchFromPath(String path) async {
    final response = await http.get(Uri.parse('$_rootUrl/$path.json'));
    if (response.statusCode != 200) return <String, dynamic>{};
    final body = response.body.trim();
    if (body.isEmpty || body == 'null') return <String, dynamic>{};
    final dynamic decoded = json.decode(body);
    return _normalize(decoded);
  }

  Map<String, dynamic> _normalize(dynamic source) {
    if (source is Map) {
      final map = <String, dynamic>{};
      source.forEach((key, value) {
        map[key.toString()] = value;
      });
      return map;
    }
    if (source is List) {
      final map = <String, dynamic>{};
      for (var i = 0; i < source.length; i++) {
        final value = source[i];
        if (value != null) {
          map[i.toString()] = value;
        }
      }
      return map;
    }
    return <String, dynamic>{};
  }
}
