import 'package:flutter/material.dart';

class SubSectionViewMobile extends StatelessWidget {
  final String name;
  const SubSectionViewMobile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Vista Mobile: $name',
        style: const TextStyle(color: Color(0xFF00E6FB), fontSize: 22),
      ),
    );
  }
}
