import 'package:flutter/material.dart';
import 'package:led_management_software/features/dashboard/model/dashboard_kpi_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/live_metric_card.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class DashboardKpiCard extends StatelessWidget {
  const DashboardKpiCard({required this.item, super.key});

  final DashboardKpiModel item;

  @override
  Widget build(BuildContext context) {
    return LiveMetricCard(
      title: item.label,
      value: item.value,
      delta: item.change,
      status: item.positive ? StatusBadgeType.ready : StatusBadgeType.queued,
    );
  }
}
