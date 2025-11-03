import '../model/panel_model.dart';
import 'package:flutter/material.dart';

class PanelController extends ChangeNotifier {
  final PanelModel _model = PanelModel();
  String get user => _model.user;

  void setUser(String value) {
    _model.user = value;
    notifyListeners();
  }
}
