import 'package:flutter/material.dart';
import 'package:led_management_software/features/live_control/model/live_cue_model.dart';
import 'package:led_management_software/shared/widgets/surfaces/queue_item_card.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class LiveCueCard extends StatelessWidget {
  const LiveCueCard({required this.cue, super.key});

  final LiveCueModel cue;

  @override
  Widget build(BuildContext context) {
    return QueueItemCard(
      title: cue.title,
      subtitle: '${cue.category} • ${cue.status}',
      status: StatusBadgeType.queued,
    );
  }
}
