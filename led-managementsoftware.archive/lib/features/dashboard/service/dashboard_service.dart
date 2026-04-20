import 'package:led_management_software/features/dashboard/model/dashboard_kpi_model.dart';

class DashboardService {
  const DashboardService();

  List<DashboardKpiModel> loadKpis() {
    return const [
      DashboardKpiModel(label: 'Aktive Outputs', value: '4', change: '+1 heute', positive: true),
      DashboardKpiModel(label: 'Medienclips', value: '286', change: '+12 letzte Woche', positive: true),
      DashboardKpiModel(label: 'Queue-Latenz', value: '38 ms', change: '-6 ms', positive: true),
      DashboardKpiModel(label: 'Warnungen', value: '2', change: '+1 offen', positive: false),
    ];
  }

  List<String> loadAlerts() {
    return const [
      'Encoder 2 meldet verzögertes Frame-Pacing',
      'Projekt „Arena Nord“ nicht vollständig synchronisiert',
      'Backup-Ausgabe wurde seit 45 Min nicht getestet',
    ];
  }
}
