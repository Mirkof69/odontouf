import 'package:flutter/material.dart';
import '../controller/login_controller.dart';
import 'package:provider/provider.dart';
import '../../panel_administrativo/view/panel_view_mobile.dart';

class LoginViewMobile extends StatelessWidget {
  final LoginController controller;
  const LoginViewMobile({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginController>.value(
      value: controller,
      child: const _LoginMobileBody(),
    );
  }
}

class _LoginMobileBody extends StatefulWidget {
  const _LoginMobileBody();

  @override
  State<_LoginMobileBody> createState() => _LoginMobileBodyState();
}

class _LoginMobileBodyState extends State<_LoginMobileBody> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/assets/images/logo_clinica.png', height: 180),
                const SizedBox(height: 32),
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
                                  builder: (_) => const PanelViewMobile(),
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
      ),
    );
  }
}
