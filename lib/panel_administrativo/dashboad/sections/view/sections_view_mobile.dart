import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/sections_controller.dart';

typedef OnSubSectionTap = void Function(String section, String subSection);

class SectionsViewMobile extends StatelessWidget {
  final OnSubSectionTap onSubSectionTap;
  final String? selectedSection;
  final String? selectedSubSection;
  const SectionsViewMobile({
    super.key,
    required this.onSubSectionTap,
    this.selectedSection,
    this.selectedSubSection,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SectionsController(),
      child: _SectionsMobileBody(
        onSubSectionTap: onSubSectionTap,
        selectedSection: selectedSection,
        selectedSubSection: selectedSubSection,
      ),
    );
  }
}

class _SectionsMobileBody extends StatelessWidget {
  final OnSubSectionTap onSubSectionTap;
  final String? selectedSection;
  final String? selectedSubSection;
  const _SectionsMobileBody({
    required this.onSubSectionTap,
    this.selectedSection,
    this.selectedSubSection,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SectionsController>(context);
    return ListView(
      children: [
        for (int i = 0; i < controller.sections.length; i++)
          ExpansionTile(
            backgroundColor: const Color(0xFF181A1B),
            collapsedBackgroundColor: const Color.fromARGB(255, 7, 199, 157),
            textColor: const Color(0xFF00E6FB),
            iconColor: const Color(0xFF00E6FB),
            collapsedIconColor: Colors.white70,
            title: Text(controller.sections[i].name),
            initiallyExpanded: controller.sections[i].expanded,
            onExpansionChanged: (_) => controller.toggleSection(i),
            children: [
              for (final sub in controller.sections[i].subSections)
                ListTile(
                  title: Text(
                    sub,
                    style: TextStyle(
                      color:
                          selectedSection == controller.sections[i].name &&
                              selectedSubSection == sub
                          ? const Color(0xFF00E6FB)
                          : Colors.white,
                      fontWeight:
                          selectedSection == controller.sections[i].name &&
                              selectedSubSection == sub
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected:
                      selectedSection == controller.sections[i].name &&
                      selectedSubSection == sub,
                  onTap: () =>
                      onSubSectionTap(controller.sections[i].name, sub),
                ),
            ],
          ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(color: Colors.redAccent),
          ),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF23272A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  '¿Cerrar sesión?',
                  style: TextStyle(color: Color(0xFF00E6FB)),
                ),
                content: const Text(
                  '¿Estás seguro de que deseas cerrar sesión?',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E6FB),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              // TODO: Acción de logout real
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ],
    );
  }
}
