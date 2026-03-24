import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/core/theme/app_shadows.dart';
import 'package:led_management_software/domain/enums/live_action_type.dart';
import 'package:led_management_software/features/live_control/model/live_action_config.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class LiveEventButton extends StatefulWidget {
  const LiveEventButton({
    required this.action,
    required this.onPressed,
    super.key,
  });

  final LiveActionConfig action;
  final VoidCallback onPressed;

  @override
  State<LiveEventButton> createState() => _LiveEventButtonState();
}

class _LiveEventButtonState extends State<LiveEventButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final semanticColor = _colorFor(action.color);
    final destructive = action.actionType == LiveActionType.stopCue;
    final accent = destructive ? AppColors.error : semanticColor;
    final borderColor = _hovered ? accent : AppColors.border;
    final background = _pressed
        ? AppColors.surfaceStrong
        : _hovered
            ? AppColors.surfaceMuted
            : AppColors.surface;
    final scale = _pressed ? 0.992 : _hovered ? 1.006 : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: TweenAnimationBuilder<double>(
          duration: AppDurations.fast,
          tween: Tween(begin: 1, end: scale),
          builder: (context, value, child) => Transform.scale(scale: value, child: child),
          child: AnimatedContainer(
            duration: AppDurations.medium,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: _hovered ? AppShadows.glow(accent) : AppShadows.panel,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppDurations.medium,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: accent.withValues(alpha: 0.7)),
                  ),
                  child: Icon(_iconForAction(action), size: 22, color: accent),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _subtitleFor(action),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if ((action.hotkey ?? '').isNotEmpty)
                      StatusBadge(
                        label: action.hotkey!,
                        type: StatusBadgeType.hover,
                        compact: true,
                      ),
                    const SizedBox(height: AppSpacing.xs),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: accent.withValues(alpha: 0.9)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(LiveActionConfig action) {
    return switch (action.actionType) {
      LiveActionType.stopCue => 'Sofortiger Stop-Befehl',
      LiveActionType.blackScreenOn => 'Sicherheitsmodus: Black Screen',
      _ => switch (action.group) {
          LiveActionGroup.game => 'Spielaktion • sofort auslösen',
          LiveActionGroup.advertising => 'Werbeaktion • kontrolliert schalten',
          LiveActionGroup.safety => 'Sicherheitsaktion',
          LiveActionGroup.intro => 'Intro-/Player-Aktion',
        },
    };
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
