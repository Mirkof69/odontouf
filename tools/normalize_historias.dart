import 'dart:convert';
import 'dart:io';

/*
  Script para normalizar paciente_id en historias_clinicas en Firebase Realtime Database.

  Uso:
    - Exporta las variables de entorno:
        $env:FIREBASE_DB_URL = 'https://<project>.firebaseio.com'
        # opcional: $env:FIREBASE_AUTH = '<database-secret-or-auth-token>'
    - Dry-run (solo mostrar cambios propuestos):
        dart run tools/normalize_historias.dart
    - Aplicar cambios (PATCH):
        dart run tools/normalize_historias.dart --apply

  Nota: El script hace backup local de `historias_clinicas` antes de aplicar cambios.
*/

final _dbUrl = Platform.environment['FIREBASE_DB_URL'];
final _auth = Platform.environment['FIREBASE_AUTH'];

String _authQuery() => _auth == null || _auth!.isEmpty
    ? ''
    : '?auth=${Uri.encodeComponent(_auth!)}';

Uri _buildUri(String path) {
  final uriStr =
      '${_dbUrl!.replaceAll(RegExp(r'/+\z'), '')}/$path.json${_authQuery()}';
  return Uri.parse(uriStr);
}

Future<Map<String, dynamic>> _getJson(String path) async {
  final uri = _buildUri(path);
  final client = HttpClient();
  final req = await client.getUrl(uri);
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  client.close();
  if (res.statusCode >= 400) {
    throw HttpException('GET $uri -> ${res.statusCode}: $body');
  }
  if (body.trim().isEmpty || body.trim() == 'null') return {};
  return jsonDecode(body) as Map<String, dynamic>;
}

Future<dynamic> _getJsonDynamic(String path) async {
  final uri = _buildUri(path);
  final client = HttpClient();
  final req = await client.getUrl(uri);
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  client.close();
  if (res.statusCode >= 400) {
    throw HttpException('GET $uri -> ${res.statusCode}: $body');
  }
  if (body.trim().isEmpty || body.trim() == 'null') return {};
  return jsonDecode(body);
}

Future<void> _patchJson(String path, Map<String, dynamic> payload) async {
  final uri = _buildUri(path);
  final client = HttpClient();
  final req = await client.openUrl('PATCH', uri);
  req.headers.contentType = ContentType.json;
  req.add(utf8.encode(jsonEncode(payload)));
  final res = await req.close();
  final body = await res.transform(utf8.decoder).join();
  client.close();
  if (res.statusCode >= 400) {
    throw HttpException('PATCH $uri -> ${res.statusCode}: $body');
  }
}

String _norm(String? s) =>
    s?.toString().trim().replaceAll(RegExp(r'^0+'), '') ?? '';

void main(List<String> args) async {
  if (_dbUrl == null || _dbUrl!.isEmpty) {
    stderr.writeln(
      'ERROR: Debes exportar la variable de entorno FIREBASE_DB_URL (ej: https://<project>.firebaseio.com)',
    );
    exit(1);
  }

  final apply = args.contains('--apply');
  stdout.writeln('Firebase DB: $_dbUrl');
  stdout.writeln('Modo: ${apply ? 'APLICAR cambios' : 'DRY-RUN (no aplica)'}');

  try {
    stdout.writeln('Listando la raíz de la base de datos...');
    final root = await _getJson('');
    // Detectar rutas reales (ej: 'Pacientes', 'HistoriasClinicas') buscando coincidencias insensibles a mayúsculas
    String? findKeyContaining(Map<String, dynamic> m, String token) {
      final lower = token.toLowerCase();
      for (final k in m.keys) {
        if (k.toLowerCase().contains(lower)) return k;
      }
      return null;
    }

    final pacientesPath = findKeyContaining(root, 'pacient') ?? 'pacientes';
    final historiasPath =
        findKeyContaining(root, 'historia') ?? 'historias_clinicas';

    stdout.writeln('Usando ruta para Pacientes: $pacientesPath');
    stdout.writeln('Usando ruta para Historias: $historiasPath');

    stdout.writeln('Descargando pacientes...');
    final pacientesRaw = await _getJson(pacientesPath);
    final pacientes = <String, Map<String, dynamic>>{}; // key -> map
    final byIdPaciente = <String, Map<String, dynamic>>{};
    final byCi = <String, Map<String, dynamic>>{};
    final byNumeroHistoria = <String, Map<String, dynamic>>{};

    pacientesRaw.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        pacientes[k] = v;
        final id = v['id_paciente']?.toString() ?? '';
        final ci = v['ci']?.toString() ?? '';
        final numHistoria =
            v['numero_historia_clinica']?.toString() ??
            v['numeroHistoriaClinica']?.toString() ??
            '';
        if (id.isNotEmpty) byIdPaciente[_norm(id)] = v;
        if (ci.isNotEmpty) byCi[_norm(ci)] = v;
        if (numHistoria.isNotEmpty) byNumeroHistoria[_norm(numHistoria)] = v;
      }
    });

    stdout.writeln('Pacientes cargados: ${pacientes.length}');

    stdout.writeln('Descargando historias desde: $historiasPath ...');
    final historiasRawDynamic = await _getJsonDynamic(historiasPath);
    final Map<String, dynamic> historiasRaw = {};
    if (historiasRawDynamic is Map<String, dynamic>) {
      historiasRaw.addAll(historiasRawDynamic);
    } else if (historiasRawDynamic is List) {
      // convertir lista en map con keys por índice
      for (var i = 0; i < historiasRawDynamic.length; i++) {
        final v = historiasRawDynamic[i];
        if (v is Map<String, dynamic>) {
          historiasRaw[i.toString()] = v;
        } else {
          historiasRaw[i.toString()] = {'value': v};
        }
      }
    }
    if (historiasRaw.isEmpty) {
      stdout.writeln(
        'No se encontraron historias en la ruta $historiasPath. Nada que hacer.',
      );
      return;
    }

    final changes = <String, Map<String, String>>{}; // key -> {current, target}

    historiasRaw.forEach((key, value) {
      if (value is! Map<String, dynamic>) return;
      // posibles campos con paciente id: 'paciente_id', 'pacienteId'
      final currentRaw =
          (value['paciente_id'] ?? value['pacienteId'] ?? '')?.toString() ?? '';
      final currentNorm = _norm(currentRaw);

      String? targetId;

      // 1) si ya coincide con id_paciente
      if (currentNorm.isNotEmpty && byIdPaciente.containsKey(currentNorm)) {
        targetId = byIdPaciente[currentNorm]!['id_paciente']?.toString();
      }

      // 2) intentar por CI
      if (targetId == null || targetId.isEmpty) {
        if (currentNorm.isNotEmpty && byCi.containsKey(currentNorm)) {
          targetId = byCi[currentNorm]!['id_paciente']?.toString();
        }
      }

      // 3) intentar por numero historia clinica
      if (targetId == null || targetId.isEmpty) {
        if (currentNorm.isNotEmpty &&
            byNumeroHistoria.containsKey(currentNorm)) {
          targetId = byNumeroHistoria[currentNorm]!['id_paciente']?.toString();
        }
      }

      // 4) como último recurso, si historia tiene campo numero_historia_clinica o 'paciente' con estructura
      if (targetId == null || targetId.isEmpty) {
        final numHist =
            (value['numero_historia_clinica'] ??
                    value['numeroHistoriaClinica'] ??
                    '')
                ?.toString() ??
            '';
        final n = _norm(numHist);
        if (n.isNotEmpty && byNumeroHistoria.containsKey(n)) {
          targetId = byNumeroHistoria[n]!['id_paciente']?.toString();
        }
      }

      // Now decide
      if (targetId != null && targetId.isNotEmpty) {
        final tNorm = _norm(targetId);
        if (tNorm != currentNorm) {
          changes[key] = {'current': currentRaw, 'target': targetId};
        }
      }
    });

    stdout.writeln(
      'Historias a actualizar: ${changes.length} / ${historiasRaw.length}',
    );

    if (changes.isEmpty) {
      stdout.writeln('No se detectaron cambios necesarios.');
      return;
    }

    // Mostrar resumen
    var shown = 0;
    changes.forEach((k, v) {
      if (shown < 20) {
        stdout.writeln(' - $k : ${v['current']} -> ${v['target']}');
        shown++;
      }
    });
    if (changes.length > 20) {
      stdout.writeln('  ... (mostrar solo 20 de ${changes.length})');
    }

    if (!apply) {
      stdout.writeln(
        'Dry-run terminado. Ejecuta con --apply para aplicar los cambios.',
      );
      return;
    }

    // backup
    final backupFile = File(
      'backup_historias_clinicas_${DateTime.now().toIso8601String()}.json',
    );
    await backupFile.writeAsString(jsonEncode(historiasRaw));
    stdout.writeln('Backup guardado en ${backupFile.path}');

    // aplicar cambios
    var succeeded = 0;
    var failed = 0;
    for (final entry in changes.entries) {
      final key = entry.key;
      final target = entry.value['target']!;
      try {
        await _patchJson('$historiasPath/$key', {'paciente_id': target});
        succeeded++;
        stdout.writeln('PATCH OK $key -> $target');
      } catch (e) {
        failed++;
        stderr.writeln('ERROR al aplicar $key : $e');
      }
    }

    stdout.writeln(
      'Aplicación completada. éxito: $succeeded , fallos: $failed',
    );
  } catch (e, st) {
    stderr.writeln('Fallo durante el proceso: $e');
    stderr.writeln(st);
    exit(2);
  }
}
