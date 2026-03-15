import 'package:flutter/material.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/shared/widgets/controls/large_action_button.dart';

class LiveEventButton extends StatelessWidget {
  const LiveEventButton({
    required this.label,
    required this.onPressed,
    this.semanticColor = AppColors.primary,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final Color semanticColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: semanticColor),
        ),
        child: LargeActionButton(
          label: label,
          icon: _iconForLabel(label),
          onPressed: onPressed,
          destructive: label == 'Stop',
        ),
      ),
    );
  }

  IconData _iconForLabel(String value) {
    switch (value) {
      case 'Tor':
        return Icons.sports_handball_rounded;
      case 'Zeitstrafe':
        return Icons.timer_rounded;
      case 'Gelbe Karte':
        return Icons.style_rounded;
      case 'Rote Karte':
        return Icons.report_rounded;
      case 'Timeout':
        return Icons.pause_circle_filled_rounded;
      case 'Wischer':
        return Icons.cleaning_services_rounded;
      case 'Sponsor Loop':
        return Icons.autorenew_rounded;
      case 'Black Screen':
        return Icons.tv_off_rounded;
      case 'Stop':
        return Icons.stop_rounded;
      case 'Nächster Spieler':
        return Icons.skip_next_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }
}
