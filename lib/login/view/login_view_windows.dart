import 'package:flutter/material.dart';
import '../controller/login_controller.dart';
import 'package:provider/provider.dart';
import '../../panel_administrativo/view/panel_view_windows.dart';

class LoginViewWindows extends StatelessWidget {
  final LoginController controller;
  const LoginViewWindows({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginController>.value(
      value: controller,
      child: const _LoginWindowsBody(),
    );
  }
}

class _LoginWindowsBody extends StatefulWidget {
  const _LoginWindowsBody();

  @override
  State<_LoginWindowsBody> createState() => _LoginWindowsBodyState();
}

class _LoginWindowsBodyState extends State<_LoginWindowsBody> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.1 * 255).toInt()),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('lib/assets/images/logo_clinica.png', height: 220),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                ),
                onChanged: controller.setEmail,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                obscureText: _obscure,
                onChanged: controller.setPassword,
              ),
              const SizedBox(height: 24),
              controller.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // Capture navigator and messenger before the async gap
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final ok = await controller.login();
                          if (!mounted) return;
                          if (ok && controller.rol == 'Administrativo') {
                            navigator.pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const PanelViewWindows(),
                              ),
                            );
                          } else if (ok) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Acceso denegado: solo usuarios Administrativos pueden ingresar al panel.',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Iniciar sesión'),
                      ),
                    ),
              if (controller.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    controller.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
