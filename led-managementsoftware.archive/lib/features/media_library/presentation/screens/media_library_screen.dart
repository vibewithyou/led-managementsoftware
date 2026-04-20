import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:led_management_software/app/routing/app_route.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/entities/media_asset_entity.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/features/media_library/controller/media_library_controller.dart';
import 'package:led_management_software/features/media_library/model/media_library_view_models.dart';
import 'package:led_management_software/features/media_library/widgets/media_clip_tile.dart';
import 'package:led_management_software/features/media_library/widgets/media_edit_dialog.dart';
import 'package:led_management_software/features/media_library/widgets/media_import_dialog.dart';
import 'package:led_management_software/shared/utils/media_formatters.dart';
import 'package:led_management_software/shared/widgets/inputs/search_input.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';

class MediaLibraryScreen extends StatefulWidget {
  const MediaLibraryScreen({super.key});

  @override
  State<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends State<MediaLibraryScreen> {
  late final MediaLibraryController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool _showGrid = false;
  bool _showAdvancedFilters = false;
  bool _useGridView = true;
  bool _showDetailsOnSmall = false;

  @override
  void initState() {
    super.initState();
    _controller = MediaLibraryController();
    _controller.load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _showGrid = true;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final width = MediaQuery.sizeOf(context).width;
        final hasDetailPane = width >= 1280;
        final hasMediumLayout = width >= 980 && width < 1280;
        final coreCategories = [
          null,
          MediaCategory.sponsor,
          MediaCategory.player,
          MediaCategory.event,
          MediaCategory.general,
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Medienbibliothek',
              description: 'Suche, Import und projektbezogene Vorbereitung aller Clips.',
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: SearchInput(
                    hintText: 'Suchen nach Titel, Tags, Sponsor, Spieler...',
                    controller: _searchController,
                    onChanged: _controller.updateSearchQuery,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  tooltip: 'Suche zurücksetzen',
                  onPressed: _controller.searchQuery.isEmpty
                      ? null
                      : () {
                          _searchController.clear();
                          _controller.updateSearchQuery('');
                        },
                  icon: const Icon(Icons.clear_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: _pickAndImportClip,
                  icon: const Icon(Icons.file_upload_rounded),
                  label: const Text('Clip importieren'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: coreCategories
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_categoryChipLabel(category)),
                          selected: _controller.selectedCategory == category,
                          onSelected: (_) => _controller.selectCategory(category),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showAdvancedFilters = !_showAdvancedFilters),
                  icon: Icon(_showAdvancedFilters ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                  label: const Text('Erweiterte Filter'),
                ),
                const SizedBox(width: AppSpacing.sm),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: true, label: Text('Grid'), icon: Icon(Icons.grid_view_rounded)),
                    ButtonSegment<bool>(value: false, label: Text('Liste'), icon: Icon(Icons.view_list_rounded)),
                  ],
                  selected: {_useGridView},
                  onSelectionChanged: (value) => setState(() => _useGridView = value.first),
                ),
                const Spacer(),
                Text('${_controller.assets.length} Clips', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            if (_showAdvancedFilters) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildAdvancedFilterSection(context),
            ],
            const SizedBox(height: AppSpacing.md),
            if (_controller.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  _controller.error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ),
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasDetailPane
                      ? Row(
                          children: [
                            Expanded(flex: 3, child: _buildAssetBrowser(context, width)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: _buildDetailsPanel(context)),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(child: _buildAssetBrowser(context, width)),
                            if (hasMediumLayout && _controller.selectedAsset != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(height: 280, child: _buildDetailsPanel(context)),
                            ] else if (!hasMediumLayout && _controller.selectedAsset != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => setState(() => _showDetailsOnSmall = !_showDetailsOnSmall),
                                  icon: Icon(_showDetailsOnSmall ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                                  label: const Text('Details anzeigen'),
                                ),
                              ),
                              if (_showDetailsOnSmall)
                                SizedBox(
                                  height: 280,
                                  child: _buildDetailsPanel(context),
                                ),
                            ],
                          ],
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdvancedFilterSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: const Text('Nur Favoriten'),
                selected: _controller.onlyFavorites,
                onSelected: _controller.setOnlyFavorites,
              ),
              FilterChip(
                label: const Text('Nur Locked Sponsor'),
                selected: _controller.onlyLockedSponsor,
                onSelected: _controller.setOnlyLockedSponsor,
              ),
              FilterChip(
                label: const Text('Nur fehlende Dateien'),
                selected: _controller.onlyMissingFiles,
                onSelected: _controller.setOnlyMissingFiles,
              ),
              DropdownButton<MediaLibrarySortMode>(
                value: _controller.sortMode,
                items: const [
                  DropdownMenuItem(value: MediaLibrarySortMode.importedNewest, child: Text('Sortierung: Neueste zuerst')),
                  DropdownMenuItem(value: MediaLibrarySortMode.alphabetical, child: Text('Sortierung: Alphabetisch')),
                  DropdownMenuItem(value: MediaLibrarySortMode.category, child: Text('Sortierung: Kategorie')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _controller.setSortMode(value);
                  }
                },
              ),
            ],
          ),
          if (_controller.lastImportWarning != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _controller.lastImportWarning!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssetBrowser(BuildContext context, double width) {
    return AppPanel(
      title: _useGridView ? 'Clip-Grid' : 'Clip-Liste',
      child: AnimatedOpacity(
        opacity: _showGrid ? 1 : 0,
        duration: AppDurations.slow,
        child: _controller.assets.isEmpty
            ? const Center(
                child: Text('Keine Treffer für die aktuelle Suche/Filter.\nPasse Filter an oder importiere einen Clip.'),
              )
            : _useGridView
                ? GridView.builder(
                    itemCount: _controller.assets.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridCountForWidth(width),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.12,
                    ),
                    itemBuilder: (_, index) => _buildTileItem(_controller.assets[index]),
                  )
                : ListView.separated(
                    itemCount: _controller.assets.length,
                    itemBuilder: (_, index) => SizedBox(height: 170, child: _buildTileItem(_controller.assets[index])),
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  ),
      ),
    );
  }

  Widget _buildTileItem(MediaAssetEntity asset) {
    final isNew = asset.id == _controller.lastImportedId;
    return MediaClipTile(
      key: ValueKey(asset.id),
      asset: asset,
      isSelected: _controller.selectedAsset?.id == asset.id,
      animateIn: isNew,
      fileStatus: _controller.fileStatusFor(asset),
      onTap: () {
        _controller.selectAsset(asset);
        if (isNew) {
          _controller.clearLastImportedId();
        }
      },
      onEdit: () => _openEditDialog(asset),
      onDelete: () => _deleteAsset(asset),
    );
  }

  Widget _buildDetailsPanel(BuildContext context) {
    return AppPanel(
      title: 'Details und Nutzung',
      child: _buildDetails(context),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final selected = _controller.selectedAsset;
    if (selected == null) {
      return const Center(child: Text('Clip auswählen, um Details zu sehen.'));
    }

    return ListView(
      children: [
        _detailSection(
          context,
          title: 'Medieninfo',
          children: [
            _detailRow(context, 'Titel', selected.title),
            _detailRow(context, 'Kategorie', _categoryLabel(selected.category)),
            _detailRow(context, 'Cue-Typ', _cueTypeLabel(selected.cueType)),
            _detailRow(context, 'Dauer', formatDurationMs(selected.durationMs)),
            _detailRow(context, 'Tags', selected.tags.join(', ').isEmpty ? '-' : selected.tags.join(', ')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _detailSection(
          context,
          title: 'Datei und Qualität',
          children: [
            _detailRow(context, 'Datei', selected.fileName),
            _detailRow(context, 'Dateityp', (selected.fileExtension ?? 'unbekannt').toUpperCase()),
            _detailRow(context, 'Dateigröße', formatFileSize(selected.fileSizeBytes)),
            _detailRow(context, 'Pfad', selected.filePath),
            _detailRow(context, 'Metadaten', selected.metadataIncomplete ? 'Unvollständig' : 'Vollständig'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _detailSection(
          context,
          title: 'Projektbezogene Nutzung',
          children: [
            _detailRow(context, 'Sponsor', selected.sponsorName ?? '-'),
            _detailRow(context, 'Spieler', selected.playerName ?? '-'),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _usageBadgesFor(selected),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoute.projects.path),
                  icon: const Icon(Icons.assignment_turned_in_rounded),
                  label: const Text('Projektzuweisung öffnen'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoute.projects.path),
                  icon: const Icon(Icons.merge_type_rounded),
                  label: const Text('Als Eventclip vorbereiten'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                StatusBadge(
                  label: selected.isCueLocked ? 'Locked' : 'Nicht Locked',
                  type: selected.isCueLocked ? StatusBadgeType.locked : StatusBadgeType.hover,
                  compact: true,
                ),
                StatusBadge(
                  label: selected.isFavorite ? 'Favorit' : 'Standard',
                  type: selected.isFavorite ? StatusBadgeType.active : StatusBadgeType.hover,
                  compact: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _detailSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }

  List<Widget> _usageBadgesFor(MediaAssetEntity asset) {
    final badges = <Widget>[
      StatusBadge(
        label: 'Standardclip',
        type: asset.category == MediaCategory.general ? StatusBadgeType.ready : StatusBadgeType.hover,
        compact: true,
      ),
      StatusBadge(
        label: 'Sponsor',
        type: asset.category == MediaCategory.sponsor || asset.cueType == CueType.lockedSponsor
            ? StatusBadgeType.ready
            : StatusBadgeType.hover,
        compact: true,
      ),
      StatusBadge(
        label: 'Fallback',
        type: asset.cueType == CueType.fallback ? StatusBadgeType.ready : StatusBadgeType.hover,
        compact: true,
      ),
      StatusBadge(
        label: 'Spielerclip',
        type: asset.category == MediaCategory.player ? StatusBadgeType.ready : StatusBadgeType.hover,
        compact: true,
      ),
      StatusBadge(
        label: 'Eventclip',
        type: asset.category == MediaCategory.event || asset.cueType == CueType.event ? StatusBadgeType.ready : StatusBadgeType.hover,
        compact: true,
      ),
    ];
    return badges;
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  int _gridCountForWidth(double width) {
    if (width > 1850) return 4;
    if (width > 1420) return 3;
    if (width > 1020) return 2;
    return 1;
  }

  String _categoryChipLabel(MediaCategory? category) {
    if (category == null) {
      return 'Alle';
    }

    return switch (category) {
      MediaCategory.sponsor => 'Sponsor',
      MediaCategory.player => 'Spieler',
      MediaCategory.event => 'Event',
      MediaCategory.general => 'Standard',
      _ => category.name,
    };
  }

  String _categoryLabel(MediaCategory category) {
    return switch (category) {
      MediaCategory.general => 'Allgemein',
      MediaCategory.pregame => 'Vor dem Spiel',
      MediaCategory.sponsor => 'Sponsor',
      MediaCategory.introHome => 'Intro Heim',
      MediaCategory.introGuest => 'Intro Gast',
      MediaCategory.player => 'Spieler',
      MediaCategory.event => 'Event',
      MediaCategory.halftime => 'Halbzeit',
      MediaCategory.postgame => 'Nach dem Spiel',
      MediaCategory.emergency => 'Notfall',
    };
  }

  String _cueTypeLabel(CueType cueType) {
    return switch (cueType) {
      CueType.event => 'Event',
      CueType.oneShot => 'One Shot',
      CueType.loop => 'Loop',
      CueType.lockedSponsor => 'Locked Sponsor',
      CueType.fallback => 'Fallback',
    };
  }

  Future<void> _pickAndImportClip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp4', 'mov', 'mkv', 'avi'],
      withData: false,
    );

    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final selectedFile = result.files.first;
    final fileName = selectedFile.name;
    final filePath = selectedFile.path;

    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dateipfad konnte nicht gelesen werden.')),
      );
      return;
    }

    final importResult = await showDialog<MediaImportDialogResult>(
      context: context,
      builder: (_) => MediaImportDialog(fileName: fileName, filePath: filePath),
    );

    if (!mounted || importResult == null) {
      return;
    }

    try {
      final importOutcome = await _controller.importAsset(
        filePath: filePath,
        fileName: fileName,
        title: importResult.title,
        category: importResult.category,
        tags: importResult.tags,
        sponsorName: importResult.sponsorName,
        playerName: importResult.playerName,
        cueTypeValue: importResult.cueType.name,
        isCueLocked: importResult.isSponsorLocked,
        isFavorite: importResult.isFavorite,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('"${importResult.title}" importiert · Dauer ${formatDurationMs(importOutcome.durationMs)}'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1C6B3A),
          duration: const Duration(seconds: 3),
        ),
      );

      if (importOutcome.warning != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importOutcome.warning!),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (exception) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import fehlgeschlagen: $exception')),
      );
    }
  }

  Future<void> _openEditDialog(MediaAssetEntity asset) async {
    final result = await showDialog<MediaEditResult>(
      context: context,
      builder: (_) => MediaEditDialog(asset: asset),
    );

    if (!mounted || result == null) {
      return;
    }

    try {
      await _controller.updateAsset(
        asset: asset,
        title: result.title,
        category: result.category,
        tags: result.tags,
        cueType: result.cueType,
        isCueLocked: result.isCueLocked,
        isFavorite: result.isFavorite,
        sponsorName: result.sponsorName,
        playerName: result.playerName,
      );
    } catch (exception) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bearbeitung fehlgeschlagen: $exception')),
      );
    }
  }

  Future<void> _deleteAsset(MediaAssetEntity asset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clip löschen'),
        content: Text('"${asset.title}" wirklich löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await _controller.deleteAsset(asset.id);
    } catch (exception) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Löschen fehlgeschlagen: $exception')),
      );
    }
  }
}
