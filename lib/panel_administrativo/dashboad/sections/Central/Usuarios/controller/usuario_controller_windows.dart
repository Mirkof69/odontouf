import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/usuario_model.dart';
import 'iusuario_controller.dart';
import 'package:flutter/material.dart';

class UsuarioControllerWindows extends ChangeNotifier
    implements IUsuarioController {
  static const String _baseUrl =
      'https://odontobd-ec688-default-rtdb.firebaseio.com/Usuarios';
  List<Usuario> _usuarios = [];
  @override
  List<Usuario> get usuarios => _usuarios;

  @override
  Future<void> cargarUsuarios() async {
    final response = await http.get(Uri.parse('$_baseUrl.json'));
    if (response.statusCode != 200) {
      _usuarios = [];
      notifyListeners();
      return;
    }
    final Map<String, dynamic>? data = json.decode(response.body);
    if (data == null) {
      _usuarios = [];
      notifyListeners();
      return;
    }
    final usuarios = <Usuario>[];
    for (final entry in data.entries) {
      final usuario = Usuario.fromMap(Map<String, dynamic>.from(entry.value));
      usuarios.add(usuario);
    }
    _usuarios = usuarios;
    notifyListeners();
  }

  @override
  Future<void> agregarUsuario(Usuario usuario) async {
    await http.put(
      Uri.parse('$_baseUrl/${usuario.idUsuario}.json'),
      body: json.encode(usuario.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
    await cargarUsuarios();
  }

  @override
  Future<void> actualizarUsuario(
    int idUsuario,
    Usuario usuarioActualizado,
  ) async {
    await http.patch(
      Uri.parse('$_baseUrl/$idUsuario.json'),
      body: json.encode(usuarioActualizado.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
    await cargarUsuarios();
  }

  @override
  Future<void> eliminarUsuario(int idUsuario) async {
    await http.patch(
      Uri.parse('$_baseUrl/$idUsuario.json'),
      body: json.encode({'estado': 'Inactivo'}),
      headers: {'Content-Type': 'application/json'},
    );
    await cargarUsuarios();
  }

  @override
  Future<void> reactivarUsuario(int idUsuario) async {
    await http.patch(
      Uri.parse('$_baseUrl/$idUsuario.json'),
      body: json.encode({'estado': 'Activo'}),
      headers: {'Content-Type': 'application/json'},
    );
    await cargarUsuarios();
  }

  @override
  Future<Usuario?> obtenerUsuarioPorId(int idUsuario) async {
    final response = await http.get(Uri.parse('$_baseUrl/$idUsuario.json'));
    if (response.statusCode != 200 || response.body == 'null') return null;
    final data = Map<String, dynamic>.from(json.decode(response.body));
    return Usuario.fromMap(data);
  }
}
