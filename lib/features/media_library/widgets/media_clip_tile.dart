import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/core/theme/app_radius.dart';
import 'package:led_management_software/core/theme/app_shadows.dart';
import 'package:led_management_software/domain/entities/media_asset_entity.dart';
import 'package:led_management_software/shared/utils/media_formatters.dart';

class MediaClipTile extends StatefulWidget {
  const MediaClipTile({
    required this.asset,
    required this.isSelected,
    required this.onTap,
    this.animateIn = false,
    super.key,
  });

  final MediaAssetEntity asset;
  final bool isSelected;
  final VoidCallback onTap;

  /// When true the tile fades in from 0 → 1 on first build (newly imported).
  final bool animateIn;

  @override
  State<MediaClipTile> createState() => _MediaClipTileState();
}

class _MediaClipTileState extends State<MediaClipTile> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: widget.animateIn ? 0.0 : 1.0,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    if (widget.animateIn) {
      // Start fade after the frame is built to avoid jank.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fadeController.forward();
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _hovered || widget.isSelected;
    final color = isActive ? AppColors.borderStrong : AppColors.border;
    final shadow = isActive ? AppShadows.glow(AppColors.primary) : AppShadows.panel;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: AppDurations.medium,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: color),
            boxShadow: shadow,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      height: 92,
                      width: double.infinity,
                      color: AppColors.surfaceStrong,
                      alignment: Alignment.center,
                      child: widget.asset.thumbnailPath.isEmpty
                          ? const Icon(Icons.video_file_rounded, color: AppColors.textMuted, size: 30)
                          : Image.network(
                              widget.asset.thumbnailPath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.video_file_rounded, color: AppColors.textMuted, size: 30),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.asset.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (widget.asset.isCueLocked)
                        const Icon(Icons.lock_rounded, size: 16, color: AppColors.warning),
                      if (widget.asset.isFavorite)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.asset.category.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Dauer ${formatDurationMs(widget.asset.durationMs)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                  if (widget.asset.metadataIncomplete)
                    Text(
                      'Metadaten unvollständig',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                    ),
                  if ((widget.asset.sponsorName ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Sponsor: ${widget.asset.sponsorName}', style: Theme.of(context).textTheme.bodySmall),
                    ),
                  if ((widget.asset.playerName ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('Spieler: ${widget.asset.playerName}', style: Theme.of(context).textTheme.bodySmall),
                    ),
                  if (widget.asset.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.asset.tags
                            .take(4)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(tag, style: Theme.of(context).textTheme.bodySmall),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    widget.asset.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}