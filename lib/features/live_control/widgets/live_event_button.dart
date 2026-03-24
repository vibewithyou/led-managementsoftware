import 'package:flutter/material.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/domain/enums/live_action_type.dart';
import 'package:led_management_software/features/live_control/model/live_action_config.dart';
import 'package:led_management_software/shared/widgets/controls/large_action_button.dart';

class LiveEventButton extends StatelessWidget {
  const LiveEventButton({
    required this.action,
    required this.onPressed,
    super.key,
  });

  final LiveActionConfig action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final semanticColor = _colorFor(action.color);

    return Stack(
      children: [
        SizedBox(
          height: 82,
          width: double.infinity,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(primary: semanticColor),
            ),
            child: LargeActionButton(
              label: action.label,
              icon: _iconForAction(action),
              onPressed: onPressed,
              destructive: action.actionType == LiveActionType.stopCue,
            ),
          ),
        ),
        if (action.hotkey != null)
          Positioned(
            top: 8,
            right: 8,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    action.hotkey!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _colorFor(LiveActionColorSemantic semantic) {
    return switch (semantic) {
      LiveActionColorSemantic.success => AppColors.success,
      LiveActionColorSemantic.warning => AppColors.warning,
      LiveActionColorSemantic.danger => AppColors.error,
      LiveActionColorSemantic.neutral => AppColors.disabled,
      _ => AppColors.primary,
    };
  }

  IconData _iconForAction(LiveActionConfig action) {
    return switch (action.id) {
      'goal' => Icons.sports_handball_rounded,
      'penalty' => Icons.timer_rounded,
      'yellow_card' => Icons.style_rounded,
      'red_card' => Icons.report_rounded,
      'timeout' => Icons.pause_circle_filled_rounded,
      'wiper' => Icons.cleaning_services_rounded,
      'sponsor_loop' => Icons.autorenew_rounded,
      'black_screen' => Icons.tv_off_rounded,
      'stop' => Icons.stop_rounded,
      'next_player' => Icons.skip_next_rounded,
      _ => Icons.bolt_rounded,
    };
  }
}
