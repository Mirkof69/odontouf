import '../model/dashboard_model.dart';
import 'package:flutter/material.dart';

class DashboardController extends ChangeNotifier {
  final DashboardModel _model = DashboardModel();
  int _selectedIndex = 0;

  List<DashboardItem> get items => _model.items;
  int get selectedIndex => _selectedIndex;

  void selectIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
