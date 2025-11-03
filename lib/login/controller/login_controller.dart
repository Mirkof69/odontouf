import '../model/login_model.dart';
import 'login_helper.dart';
import '../../panel_administrativo/dashboad/sections/Central/Usuarios/model/usuario_model.dart';
import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final LoginModel _model = LoginModel();
  bool _isLoading = false;
  String? _error;
  Usuario? _usuarioLogueado;

  String get email => _model.email;
  String get password => _model.password;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Usuario? get usuarioLogueado => _usuarioLogueado;
  String? get rol => _usuarioLogueado?.rol;

  void setEmail(String value) {
    _model.email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _model.password = value;
    notifyListeners();
  }

  Future<bool> login() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await LoginHelper.validarUsuarioPorCorreoYPassword(
        _model.email,
        _model.password,
      );
      if (result['usuario'] != null) {
        _usuarioLogueado = result['usuario'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = result['error'] ?? 'Correo o contraseña incorrectos';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error de conexión o datos';
      notifyListeners();
      return false;
    }
  }
}
