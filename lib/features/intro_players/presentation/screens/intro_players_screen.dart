import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/enums/team_type.dart';
import 'package:led_management_software/features/intro_players/controller/intro_players_controller.dart';
import 'package:led_management_software/features/intro_players/widgets/player_intro_card.dart';
import 'package:led_management_software/shared/widgets/controls/large_action_button.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';

class IntroPlayersScreen extends StatefulWidget {
  const IntroPlayersScreen({super.key});

  @override
  State<IntroPlayersScreen> createState() => _IntroPlayersScreenState();
}

class _IntroPlayersScreenState extends State<IntroPlayersScreen> {
  late final IntroPlayersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = IntroPlayersController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final compact = MediaQuery.sizeOf(context).width < 1220;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Lineup',
              description: 'Spieler-Intro mit direkter Clip-Auswahl aus der Medienbibliothek.',
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Projekt: ${_controller.projectLabel}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
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
              child: compact
                  ? Column(
                      children: [
                        Expanded(child: _buildLineupPanel()),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(child: _buildControlPanel()),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(flex: 3, child: _buildLineupPanel()),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(flex: 2, child: _buildControlPanel()),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLineupPanel() {
    return AppPanel(
      title: 'Spielerliste',
      trailing: FilledButton.icon(
        onPressed: _openAddPlayerDialog,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
        label: const Text('Spieler hinzufügen'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ChoiceChip(
                label: const Text('Heim'),
                selected: _controller.selectedTeam == TeamType.home,
                onSelected: (_) => _controller.selectTeam(TeamType.home),
              ),
              const SizedBox(width: AppSpacing.sm),
              ChoiceChip(
                label: const Text('Gast'),
                selected: _controller.selectedTeam == TeamType.guest,
                onSelected: (_) => _controller.selectTeam(TeamType.guest),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ReorderableListView.builder(
                    itemCount: _controller.selectedItems.length,
                    onReorder: _controller.reorderSelectedTeam,
                    itemBuilder: (_, index) {
                      final item = _controller.selectedItems[index];
                      return Padding(
                        key: ValueKey(item.entry.id),
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: PlayerIntroCard(
                          item: item,
                          orderIndex: index,
                          onDelete: () => _controller.deletePlayer(item.entry.id),
                          onToggleActive: (value) => _controller.togglePlayerActive(item.entry, value),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    final activePlayer = _controller.sequenceController.activePlayer;

    return AppPanel(
      title: 'Intro-Steuerung',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(begin: const Offset(0.25, 0), end: Offset.zero).animate(animation);
              return SlideTransition(position: offset, child: child);
            },
            child: Container(
              key: ValueKey('${activePlayer?.id}_${_controller.sequenceController.statusMessage}'),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_controller.sequenceController.statusMessage, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Spieler: ${activePlayer?.playerName ?? '-'}'),
                  Text('Clip: ${activePlayer?.clipTitle ?? '-'}'),
                  Text('Kategorie: ${activePlayer?.category ?? '-'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 74,
            width: double.infinity,
            child: LargeActionButton(
              label: 'Intro starten',
              icon: Icons.play_arrow_rounded,
              onPressed: _controller.startIntro,
              active: _controller.sequenceController.isRunning,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 74,
            width: double.infinity,
            child: LargeActionButton(
              label: 'Vorheriger Spieler',
              icon: Icons.skip_previous_rounded,
              onPressed: _controller.playPreviousPlayer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 74,
            width: double.infinity,
            child: LargeActionButton(
              label: 'Nächster Spieler',
              icon: Icons.skip_next_rounded,
              onPressed: _controller.playNextPlayer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 74,
            width: double.infinity,
            child: LargeActionButton(
              label: 'Spieler überspringen',
              icon: Icons.fast_forward_rounded,
              onPressed: _controller.skipCurrentPlayer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 74,
            width: double.infinity,
            child: LargeActionButton(
              label: 'Endclip',
              icon: Icons.stop_circle_outlined,
              onPressed: _controller.playEndClip,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddPlayerDialog() async {
    final result = await showDialog<_AddPlayerDialogResult>(
      context: context,
      builder: (_) => _AddPlayerDialog(
        initialTeam: _controller.selectedTeam,
        clips: _controller.availableClips,
      ),
    );

    if (result == null) {
      return;
    }

    await _controller.addPlayer(
      playerName: result.playerName,
      mediaAssetId: result.mediaAssetId,
      teamType: result.teamType,
      isActive: result.isActive,
    );
  }
}

class _AddPlayerDialogResult {
  const _AddPlayerDialogResult({
    required this.playerName,
    required this.mediaAssetId,
    required this.teamType,
    required this.isActive,
  });

  final String playerName;
  final String mediaAssetId;
  final TeamType teamType;
  final bool isActive;
}

class _AddPlayerDialog extends StatefulWidget {
  const _AddPlayerDialog({
    required this.initialTeam,
    required this.clips,
  });

  final TeamType initialTeam;
  final List<MediaAsset> clips;

  @override
  State<_AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<_AddPlayerDialog> {
  late final TextEditingController _playerNameController;
  late final TextEditingController _clipSearchController;
  TeamType _teamType = TeamType.home;
  bool _isActive = true;
  String? _selectedClipId;

  @override
  void initState() {
    super.initState();
    _playerNameController = TextEditingController();
    _clipSearchController = TextEditingController();
    _teamType = widget.initialTeam;
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _clipSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredClips = widget.clips
        .where(
          (clip) => clip.title.toLowerCase().contains(_clipSearchController.text.trim().toLowerCase()),
        )
        .toList(growable: false);

    return AlertDialog(
      title: const Text('Spieler hinzufügen'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _playerNameController,
              decoration: const InputDecoration(labelText: 'Spieler'),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<TeamType>(
              initialValue: _teamType,
              decoration: const InputDecoration(labelText: 'Team'),
              items: const [
                DropdownMenuItem(value: TeamType.home, child: Text('Heim')),
                DropdownMenuItem(value: TeamType.guest, child: Text('Gast')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _teamType = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _clipSearchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Clip suchen',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _selectedClipId,
              decoration: const InputDecoration(labelText: 'Clip'),
              items: filteredClips
                  .map(
                    (clip) => DropdownMenuItem(
                      value: clip.id,
                      child: Text('${clip.title} • ${clip.category.name}'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _selectedClipId = value),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isActive,
              title: const Text('Aktiv'),
              onChanged: (value) => setState(() => _isActive = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () {
            final player = _playerNameController.text.trim();
            final clipId = _selectedClipId;
            if (player.isEmpty || clipId == null) {
              return;
            }
            Navigator.of(context).pop(
              _AddPlayerDialogResult(
                playerName: player,
                mediaAssetId: clipId,
                teamType: _teamType,
                isActive: _isActive,
              ),
            );
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

class LineupScreen extends IntroPlayersScreen {
  const LineupScreen({super.key});
}
