import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/sections_controller.dart';

typedef SubSectionTapCallback =
    void Function(String section, String subSection);

class SectionsViewWindows extends StatelessWidget {
  final SubSectionTapCallback? onSubSectionTap;
  final String? selectedSection;
  final String? selectedSubSection;
  const SectionsViewWindows({
    super.key,
    this.onSubSectionTap,
    this.selectedSection,
    this.selectedSubSection,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SectionsController(),
      child: _SectionsWindowsBody(
        onSubSectionTap: onSubSectionTap,
        selectedSection: selectedSection,
        selectedSubSection: selectedSubSection,
      ),
    );
  }
}

class _SectionsWindowsBody extends StatelessWidget {
  final SubSectionTapCallback? onSubSectionTap;
  final String? selectedSection;
  final String? selectedSubSection;
  const _SectionsWindowsBody({
    this.onSubSectionTap,
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
                          controller.sections[i].name == selectedSection &&
                              sub == selectedSubSection
                          ? const Color(0xFF00E6FB)
                          : Colors.white,
                      fontWeight:
                          controller.sections[i].name == selectedSection &&
                              sub == selectedSubSection
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected:
                      controller.sections[i].name == selectedSection &&
                      sub == selectedSubSection,
                  onTap: () {
                    if (onSubSectionTap != null) {
                      onSubSectionTap!(controller.sections[i].name, sub);
                    }
                  },
                ),
            ],
          ),
      ],
    );
  }
}
