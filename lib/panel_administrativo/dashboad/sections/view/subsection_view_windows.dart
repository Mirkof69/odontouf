import 'package:flutter/material.dart';

class SubSectionViewWindows extends StatelessWidget {
  final String name;
  const SubSectionViewWindows({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Vista Windows: $name',
        style: const TextStyle(color: Color(0xFF00E6FB), fontSize: 24),
      ),
    );
  }
}
