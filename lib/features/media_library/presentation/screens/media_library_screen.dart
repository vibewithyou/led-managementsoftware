import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/core/theme/app_durations.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/features/media_library/controller/media_library_controller.dart';
import 'package:led_management_software/features/media_library/widgets/media_clip_tile.dart';
import 'package:led_management_software/features/media_library/widgets/media_import_dialog.dart';
import 'package:led_management_software/shared/widgets/inputs/search_input.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';

/// Main media library workspace for clip import, search, filtering and detail preview.
class MediaLibraryScreen extends StatefulWidget {
  const MediaLibraryScreen({super.key});

  @override
  State<MediaLibraryScreen> createState() => _MediaLibraryScreenState();
}

class _MediaLibraryScreenState extends State<MediaLibraryScreen> {
  late final MediaLibraryController _controller;
  final TextEditingController _searchController = TextEditingController();
  bool _showGrid = false;

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
        final hasDetailPane = width > 1360;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: PageHeader(
                    title: 'Medienbibliothek',
                    description: 'Import, Suche und Vorbereitung aller Videoclips für den Livebetrieb.',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SearchInput(
                  hintText: 'Suchen nach Titel, Tags, Sponsor, Spieler...',
                  controller: _searchController,
                  onChanged: _controller.updateSearchQuery,
                ),
                const SizedBox(width: AppSpacing.md),
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
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Alle'),
                      selected: _controller.selectedCategory == null,
                      onSelected: (_) => _controller.selectCategory(null),
                    ),
                  ),
                  ...MediaCategory.values.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: _controller.selectedCategory == category,
                        onSelected: (_) => _controller.selectCategory(category),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
              child: Row(
                children: [
                  Expanded(
                    flex: hasDetailPane ? 3 : 1,
                    child: AppPanel(
                      title: 'Clips',
                      trailing: Text('${_controller.assets.length} Assets'),
                      child: _controller.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : AnimatedOpacity(
                              opacity: _showGrid ? 1 : 0,
                              duration: AppDurations.slow,
                              child: _controller.assets.isEmpty
                                  ? const Center(
                                      child: Text('Keine Clips vorhanden. Importiere deinen ersten Clip.'),
                                    )
                                  : GridView.builder(
                                      itemCount: _controller.assets.length,
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: _gridCountForWidth(width),
                                        mainAxisSpacing: AppSpacing.md,
                                        crossAxisSpacing: AppSpacing.md,
                                        childAspectRatio: 1.12,
                                      ),
                                      itemBuilder: (_, index) {
                                        final asset = _controller.assets[index];
                                        return MediaClipTile(
                                          asset: asset,
                                          isSelected: _controller.selectedAsset?.id == asset.id,
                                          onTap: () => _controller.selectAsset(asset),
                                        );
                                      },
                                    ),
                            ),
                    ),
                  ),
                  if (hasDetailPane) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppPanel(
                        title: 'Details',
                        child: _buildDetails(context),
                      ),
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

  Widget _buildDetails(BuildContext context) {
    final selected = _controller.selectedAsset;
    if (selected == null) {
      return const Center(child: Text('Clip auswählen, um Details zu sehen.'));
    }

    return ListView(
      children: [
        _detailRow(context, 'Titel', selected.title),
        _detailRow(context, 'Kategorie', selected.category.name),
        _detailRow(context, 'CueType', selected.cueType.name),
        _detailRow(context, 'Datei', selected.fileName),
        _detailRow(context, 'Pfad', selected.filePath),
        _detailRow(context, 'Sponsor', selected.sponsorName ?? '-'),
        _detailRow(context, 'Spieler', selected.playerName ?? '-'),
        _detailRow(context, 'Tags', selected.tags.join(', ').isEmpty ? '-' : selected.tags.join(', ')),
        _detailRow(context, 'Gesperrt', selected.isCueLocked ? 'Ja' : 'Nein'),
        _detailRow(context, 'Favorit', selected.isFavorite ? 'Ja' : 'Nein'),
      ],
    );
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
    if (width > 1850) {
      return 4;
    }
    if (width > 1450) {
      return 3;
    }
    if (width > 980) {
      return 2;
    }
    return 1;
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
      builder: (_) => MediaImportDialog(fileName: fileName),
    );

    if (!mounted || importResult == null) {
      return;
    }

    try {
      await _controller.importAsset(
        filePath: filePath,
        fileName: fileName,
        title: importResult.title,
        category: importResult.category,
        tags: importResult.tags,
        sponsorName: importResult.sponsorName,
        playerName: importResult.playerName,
        cueTypeValue: importResult.cueType.value,
        isCueLocked: importResult.isSponsorLocked,
        isFavorite: importResult.isFavorite,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clip wurde importiert.')),
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import fehlgeschlagen: $exception')),
      );
    }
  }
}
