import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/config/app_demo_data.dart';
import 'package:led_managementsoftware_app/core/routing/app_section.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({
    required this.currentSection,
    required this.compact,
    required this.onSelect,
    this.onToggleCompact,
    super.key,
  });

  final AppSection currentSection;
  final bool compact;
  final ValueChanged<AppSection> onSelect;
  final VoidCallback? onToggleCompact;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: compact ? 96 : 292,
      margin: const EdgeInsets.fromLTRB(20, 20, 0, 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundRaised.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.info]),
                  ),
                  child: const Icon(Icons.live_tv_rounded, color: AppColors.textPrimary),
                ),
                if (!compact) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LED Regie', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('Control Tool', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  if (onToggleCompact != null)
                    IconButton(
                      onPressed: onToggleCompact,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                ] else if (onToggleCompact != null)
                  IconButton(
                    onPressed: onToggleCompact,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final section in AppDemoData.primarySections)
                  _SidebarItem(
                    section: section,
                    compact: compact,
                    selected: section == currentSection,
                    onTap: () => onSelect(section),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: compact
                  ? const Column(
                      children: [
                        Icon(Icons.shield_rounded, color: AppColors.success),
                        SizedBox(height: 8),
                        StatusBadge(label: 'Live', tone: StatusBadgeTone.success, compact: true),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusBadge(label: 'Haupt-PC live', tone: StatusBadgeTone.success),
                        SizedBox(height: 10),
                        Text('Priorität aktiv', style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text(
                          'Dieses Gerät steuert die LED-Ausgabe und kann Nebengeräte jederzeit überstimmen.',
                          style: TextStyle(color: AppColors.textMuted, height: 1.4),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.section,
    required this.compact,
    required this.selected,
    required this.onTap,
  });

  final AppSection section;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary.withValues(alpha: 0.55) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(section.icon, color: selected ? AppColors.info : AppColors.textMuted),
              if (!compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}