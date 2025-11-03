import '../model/usuario_model.dart';

import 'package:flutter/material.dart';

abstract class IUsuarioController extends ChangeNotifier {
  List<Usuario> get usuarios;
  Future<void> cargarUsuarios();
  Future<void> agregarUsuario(Usuario usuario);
  Future<void> actualizarUsuario(int idUsuario, Usuario usuarioActualizado);
  Future<void> eliminarUsuario(int idUsuario);
  Future<void> reactivarUsuario(int idUsuario);
  Future<Usuario?> obtenerUsuarioPorId(int idUsuario);
}
