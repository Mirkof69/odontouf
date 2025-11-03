import 'package:flutter/material.dart';
import '../dashboad/view/dashboard_view_windows.dart';
import '../../login/controller/login_controller.dart';
import '../../login/view/login_view_windows.dart';

class PanelViewWindows extends StatelessWidget {
  const PanelViewWindows({super.key});

  static const Color neonBlue = Color(0xFF00E6FB);
  static const Color neonPink = Color(0xFFFF2D55);
  static const Color neonGreen = Color(0xFFB8FF00);
  static const Color neonOrange = Color(0xFFFFA800);
  static const Color darkBg = Color(0xFF181A1B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 199, 157),
        title: const Text(
          'Panel Administrativo (Windows)',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: const Color.fromARGB(
          255,
          6,
          179,
          78,
        ).withAlpha((0.5 * 255).toInt()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Seguro que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              );
              if (!context.mounted) return;
              if (confirm == true) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) =>
                        LoginViewWindows(controller: LoginController()),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const DashboardViewWindows(),
    );
  }
}
