import 'package:flutter/material.dart';
import '../sections/view/sections_view_mobile.dart';
import '../sections/view/subsection_view_mobile.dart';
import '../sections/Central/Usuarios/view/usuarios_view_mobile.dart';
import '../sections/Central/Pacientes/view/pacientes_view_mobile.dart';
import '../sections/Gestion_Clinica/Consultas/view/consultas_view_mobile.dart';
import '../sections/Gestion_Clinica/Historias_clinicas/view/historias_clinicas_view_mobile.dart';

class DashboardViewMobile extends StatefulWidget {
  const DashboardViewMobile({super.key});

  @override
  State<DashboardViewMobile> createState() => _DashboardViewMobileState();
}

class _DashboardViewMobileState extends State<DashboardViewMobile> {
  String? selectedSection;
  String? selectedSubSection;
  bool _menuVisible = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content fills the area and does NOT change size when the
        // menu is shown/hidden. This avoids expensive relayouts during
        // menu animation which were causing skipped frames.
        Positioned.fill(
          child: selectedSubSection == null
              ? Center(
                  child: Text(
                    'Selecciona una sección',
                    style: const TextStyle(
                      color: Color(0xFF00E6FB),
                      fontSize: 22,
                    ),
                  ),
                )
              : (selectedSection == 'Central' &&
                    selectedSubSection == 'Usuarios')
              ? const UsuariosViewMobile()
              : (selectedSection == 'Central' &&
                    selectedSubSection == 'Pacientes')
              ? const PacientesViewMobile()
              : (selectedSection == 'Gestion_Clinica' &&
                    selectedSubSection == 'Consultas')
              ? const ConsultasViewMobile()
              : (selectedSection == 'Gestion_Clinica' &&
                    selectedSubSection == 'Historias_clinicas')
              ? const HistoriasClinicasViewMobile()
              : SubSectionViewMobile(name: selectedSubSection!),
        ),
        // Sliding overlay menu (doesn't change content layout)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.ease,
          left: _menuVisible ? 0 : -260,
          top: 0,
          bottom: 0,
          width: 260,
          child: Container(
            color: const Color(0xFF181A1B),
            child: SectionsViewMobile(
              onSubSectionTap: (section, subSection) {
                setState(() {
                  selectedSection = section;
                  selectedSubSection = subSection;
                });
              },
              selectedSection: selectedSection,
              selectedSubSection: selectedSubSection,
            ),
          ),
        ),
        Positioned(
          bottom: 32,
          left: _menuVisible ? 260 : 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _menuVisible = !_menuVisible;
              });
            },
            child: Container(
              width: 32,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF23272A),
                borderRadius: BorderRadius.horizontal(
                  left: _menuVisible ? Radius.zero : const Radius.circular(16),
                  right: _menuVisible ? const Radius.circular(16) : Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                _menuVisible
                    ? Icons.arrow_back_ios_new
                    : Icons.arrow_forward_ios,
                color: const Color(0xFF00E6FB),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
