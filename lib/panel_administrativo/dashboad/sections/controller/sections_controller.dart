import '../model/sections_model.dart';
import 'package:flutter/material.dart';

class SectionsController extends ChangeNotifier {
  final SectionsModel _model = SectionsModel();
  List<Section> get sections => _model.sections;

  void toggleSection(int index) {
    _model.sections[index].expanded = !_model.sections[index].expanded;
    notifyListeners();
  }
}
