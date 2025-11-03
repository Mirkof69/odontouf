import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'iusuario_controller.dart';
import '../model/usuario_model.dart';

const String _usuariosBaseUrl =
    'https://odontobd-ec688-default-rtdb.firebaseio.com/Usuarios';

Future<List<Map<String, dynamic>>> fetchUsuariosDesdeRTDB() async {
  final response = await http.get(Uri.parse('$_usuariosBaseUrl.json'));
  if (response.statusCode != 200) {
    debugPrint('fetchUsuariosDesdeRTDB error: ${response.statusCode}');
    return [];
  }

  final dynamic data = json.decode(response.body);
  if (data == null) return [];

  if (data is Map<String, dynamic>) {
    return data.entries
        .where((entry) => entry.value is Map<String, dynamic>)
        .map((entry) {
          final map = Map<String, dynamic>.from(entry.value as Map);
          map.putIfAbsent(
            'id_usuario',
            () =>
                int.tryParse(entry.key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
          );
          return map;
        })
        .toList();
  } else if (data is List) {
    return data
        .whereType<Map>()
        .map((element) => Map<String, dynamic>.from(element))
        .toList();
  }

  return [];
}

class UsuarioController extends ChangeNotifier implements IUsuarioController {
  static const String _baseUrl = _usuariosBaseUrl;

  List<Usuario> _usuarios = [];
  bool _isLoading = false;
  bool _loaded = false;

  @override
  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _isLoading;

  @override
  Future<void> cargarUsuarios({bool force = false}) async {
    if (_isLoading) return;
    if (_loaded && !force) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl.json'));
      if (response.statusCode != 200) {
        debugPrint('Error al cargar usuarios: ${response.statusCode}');
        return;
      }

      final dynamic jsonData = json.decode(response.body);
      final parsed = _parseUsuarios(jsonData);
      _usuarios = parsed;
      _loaded = true;
    } catch (e, st) {
      debugPrint('UsuarioController.cargarUsuarios error: $e\n$st');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Usuario> _parseUsuarios(dynamic data) {
    final usuarios = <Usuario>[];
    if (data == null) return usuarios;

    if (data is Map<String, dynamic>) {
      data.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final map = Map<String, dynamic>.from(value);
          map.putIfAbsent(
            'id_usuario',
            () => int.tryParse(key.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
          );
          usuarios.add(Usuario.fromMap(map));
        }
      });
    } else if (data is List) {
      for (final entry in data) {
        if (entry is Map<String, dynamic>) {
          usuarios.add(Usuario.fromMap(entry));
        }
      }
    }

    return usuarios;
  }

  Future<void> _saveUsuario(int idUsuario, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$idUsuario.json'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode >= 400) {
      throw Exception('Error al guardar usuario (${response.statusCode})');
    }
  }

  Future<void> _patchUsuario(int idUsuario, Map<String, dynamic> body) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/$idUsuario.json'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode >= 400) {
      throw Exception('Error al actualizar usuario (${response.statusCode})');
    }
  }

  @override
  Future<void> agregarUsuario(Usuario usuario) async {
    await _saveUsuario(usuario.idUsuario, usuario.toMap());
    await cargarUsuarios(force: true);
  }

  @override
  Future<void> actualizarUsuario(
    int idUsuario,
    Usuario usuarioActualizado,
  ) async {
    await _patchUsuario(idUsuario, usuarioActualizado.toMap());
    await cargarUsuarios(force: true);
  }

  @override
  Future<void> eliminarUsuario(int idUsuario) async {
    await _patchUsuario(idUsuario, {'estado': 'Inactivo'});
    await cargarUsuarios(force: true);
  }

  @override
  Future<void> reactivarUsuario(int idUsuario) async {
    await _patchUsuario(idUsuario, {'estado': 'Activo'});
    await cargarUsuarios(force: true);
  }

  @override
  Future<Usuario?> obtenerUsuarioPorId(int idUsuario) async {
    final response = await http.get(Uri.parse('$_baseUrl/$idUsuario.json'));
    if (response.statusCode != 200) return null;
    final dynamic data = json.decode(response.body);
    if (data is! Map<String, dynamic>) return null;
    return Usuario.fromMap(Map<String, dynamic>.from(data));
  }
}
