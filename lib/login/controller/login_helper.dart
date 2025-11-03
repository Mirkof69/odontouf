import '../../panel_administrativo/dashboad/sections/Central/Usuarios/controller/usuario_controller.dart';
import '../../panel_administrativo/dashboad/sections/Central/Usuarios/model/usuario_model.dart';

class LoginHelper {
  /// Devuelve un Map con las claves: 'usuario' (Usuario?), 'error' (String?)
  static Future<Map<String, dynamic>> validarUsuarioPorCorreoYPassword(
    String email,
    String password,
  ) async {
    final usuarios = await fetchUsuariosDesdeRTDB();
    final user = usuarios.firstWhere(
      (u) => (u['email'] ?? '').toString().toLowerCase() == email.toLowerCase(),
      orElse: () => {},
    );
    if (user.isEmpty) {
      return {'usuario': null, 'error': 'Usuario no encontrado'};
    }
    // Comparación directa, NO aplicar hash, la contraseña en Firebase está en texto plano
    if ((user['contrasena_hash'] ?? '') != password) {
      return {'usuario': null, 'error': 'Contraseña incorrecta'};
    }
    return {'usuario': Usuario.fromMap(user), 'error': null};
  }
}
