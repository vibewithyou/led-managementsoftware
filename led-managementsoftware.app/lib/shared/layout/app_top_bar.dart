import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/routing/app_section.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    required this.section,
    required this.useDrawerTrigger,
    required this.backendStatusMessage,
    required this.onMenuTap,
    super.key,
  });

  final AppSection section;
  final bool useDrawerTrigger;
  final String backendStatusMessage;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          if (useDrawerTrigger)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton.filledTonal(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/branding/logo.png', fit: BoxFit.cover),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  section.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              const StatusBadge(label: 'Haupt-PC', tone: StatusBadgeTone.success),
              StatusBadge(
                label: backendStatusMessage.contains('Supabase') ? 'Supabase aktiv' : 'Offline bereit',
                tone: backendStatusMessage.contains('Supabase') ? StatusBadgeTone.success : StatusBadgeTone.info,
              ),
              const StatusBadge(label: 'Teil 4 aktiv', tone: StatusBadgeTone.warning),
            ],
          ),
        ],
      ),
    );
  }
}