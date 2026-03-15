class DashboardKpiModel {
  const DashboardKpiModel({
    required this.label,
    required this.value,
    required this.change,
    required this.positive,
  });

  final String label;
  final String value;
  final String change;
  final bool positive;
}
