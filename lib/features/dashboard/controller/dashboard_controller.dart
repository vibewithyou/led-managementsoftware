import 'package:led_management_software/features/dashboard/model/dashboard_kpi_model.dart';
import 'package:led_management_software/features/dashboard/service/dashboard_service.dart';

class DashboardController {
  DashboardController({DashboardService? service}) : _service = service ?? const DashboardService();

  final DashboardService _service;

  List<DashboardKpiModel> get kpis => _service.loadKpis();

  List<String> get alerts => _service.loadAlerts();
}
