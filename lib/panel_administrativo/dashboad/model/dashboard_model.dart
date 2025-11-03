class DashboardItem {
  final String title;
  final String icon;
  DashboardItem({required this.title, required this.icon});
}

class DashboardModel {
  final List<DashboardItem> items = [
    DashboardItem(title: 'Inicio', icon: 'home'),
    DashboardItem(title: 'Pacientes', icon: 'person'),
    DashboardItem(title: 'Consultas', icon: 'event_note'),
    DashboardItem(title: 'Reportes', icon: 'bar_chart'),
    DashboardItem(title: 'Configuración', icon: 'settings'),
  ];
}
