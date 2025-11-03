import 'package:flutter/material.dart';
import '../dashboad/view/dashboard_view_mobile.dart';

class PanelViewMobile extends StatelessWidget {
  const PanelViewMobile({super.key});

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
          'Panel Administrativo (Mobile)',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: neonBlue.withAlpha((0.5 * 255).toInt()),
      ),
      body: const DashboardViewMobile(),
    );
  }
}
