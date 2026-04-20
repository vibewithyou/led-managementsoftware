import 'package:flutter/material.dart';
import 'package:led_management_software/app/routing/app_route.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
import 'package:led_management_software/domain/entities/lineup_entry.dart';
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
        final width = MediaQuery.sizeOf(context).width;
        final compact = width < 1100;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Lineup',
              description: 'Projektbezogene Spielerliste mit kompakter Intro-Steuerung.',
            ),
            const SizedBox(height: AppSpacing.sm),
            _projectContextBar(context),
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
              child: !_controller.hasActiveProject
                  ? _buildMissingProjectState(context)
                  : compact
                      ? Column(
                          children: [
                            Expanded(flex: 7, child: _buildLineupPanel()),
                            const SizedBox(height: AppSpacing.md),
                            Expanded(flex: 5, child: _buildControlPanel()),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 7, child: _buildLineupPanel()),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(flex: 4, child: _buildControlPanel()),
                          ],
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _projectContextBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Projekt: ${_controller.projectLabel}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  _controller.hasPlayableIntroSequence
                      ? 'Intro kann gestartet werden'
                      : 'Für das gewählte Team fehlen spielbare Spielerclips',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Heim'),
            selected: _controller.selectedTeam == TeamType.home,
            onSelected: (_) => _controller.selectTeam(TeamType.home),
          ),
          const SizedBox(width: AppSpacing.xs),
          ChoiceChip(
            label: const Text('Gast'),
            selected: _controller.selectedTeam == TeamType.guest,
            onSelected: (_) => _controller.selectTeam(TeamType.guest),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingProjectState(BuildContext context) {
    return AppPanel(
      title: 'Lineup',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_busy_rounded, size: 32, color: AppColors.textMuted),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Kein aktives Projekt ausgewählt.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Wähle zuerst ein Projekt aus, damit Heim/Gast-Lineups und Intro-Steuerung verfügbar werden.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(AppRoute.projects.path),
                icon: const Icon(Icons.folder_open_rounded),
                label: const Text('Zu Projekte wechseln'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineupPanel() {
    return AppPanel(
      title: 'Spielerliste',
      trailing: FilledButton.icon(
        onPressed: _controller.hasActiveProject ? _openAddPlayerDialog : null,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
        label: const Text('Spieler hinzufügen'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _controller.selectedTeam == TeamType.home ? 'Team Heim' : 'Team Gast',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _controller.selectedItems.isEmpty
                    ? _emptyTeamState(context)
                    : ReorderableListView.builder(
                        itemCount: _controller.selectedItems.length,
                        onReorderItem: _controller.reorderSelectedTeam,
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
                              onEdit: () => _openEditPlayerDialog(item.entry),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyTeamState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Keine Spieler im aktuell gewählten Team.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Füge Spieler hinzu und weise pro Spieler einen Clip zu.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    final activePlayer = _controller.sequenceController.activePlayer;

    return AppPanel(
      title: 'Intro-Steuerung',
      child: ListView(
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
            height: 60,
            width: double.infinity,
            child: LargeActionButton(
              label: _controller.sequenceController.isRunning ? 'Intro läuft' : 'Intro starten',
              icon: Icons.play_arrow_rounded,
              onPressed: _controller.canControlIntro ? _controller.startIntro : null,
              active: _controller.sequenceController.isRunning,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: LargeActionButton(
              label: 'Nächster Spieler',
              icon: Icons.skip_next_rounded,
              onPressed: _controller.canControlIntro ? _controller.playNextPlayer : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: LargeActionButton(
              label: 'Endclip',
              icon: Icons.stop_circle_outlined,
              onPressed: _controller.hasActiveProject ? _controller.playEndClip : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Weitere Steuerung',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
            children: [
              SizedBox(
                height: 56,
                width: double.infinity,
                child: LargeActionButton(
                  label: 'Vorheriger Spieler',
                  icon: Icons.skip_previous_rounded,
                  onPressed: _controller.canControlIntro ? _controller.playPreviousPlayer : null,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: LargeActionButton(
                  label: 'Spieler überspringen',
                  icon: Icons.fast_forward_rounded,
                  onPressed: _controller.canControlIntro ? _controller.skipCurrentPlayer : null,
                ),
              ),
            ],
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
      jerseyNumber: result.jerseyNumber,
      position: result.position,
      mediaAssetId: result.mediaAssetId,
      teamType: result.teamType,
      isActive: result.isActive,
    );
  }

  Future<void> _openEditPlayerDialog(LineupEntry entry) async {
    final result = await showDialog<_AddPlayerDialogResult>(
      context: context,
      builder: (_) => _AddPlayerDialog(
        initialTeam: entry.teamType,
        clips: _controller.availableClips,
        initialName: entry.playerName,
        initialJerseyNumber: entry.jerseyNumber,
        initialPosition: entry.position,
        initialClipId: entry.introCueId,
        initialActive: entry.isActive,
        isEdit: true,
      ),
    );

    if (result == null) return;

    await _controller.updatePlayer(
      entry.copyWith(
        playerName: result.playerName,
        jerseyNumber: result.jerseyNumber,
        position: result.position,
        teamType: result.teamType,
        introCueId: result.mediaAssetId.trim().isEmpty ? null : result.mediaAssetId,
        isActive: result.isActive,
      ),
    );
  }
}

class _AddPlayerDialogResult {
  const _AddPlayerDialogResult({
    required this.playerName,
    required this.jerseyNumber,
    required this.position,
    required this.mediaAssetId,
    required this.teamType,
    required this.isActive,
  });

  final String playerName;
  final String jerseyNumber;
  final String position;
  final String mediaAssetId;
  final TeamType teamType;
  final bool isActive;
}

class _AddPlayerDialog extends StatefulWidget {
  const _AddPlayerDialog({
    required this.initialTeam,
    required this.clips,
    this.initialName = '',
    this.initialJerseyNumber = '',
    this.initialPosition = '',
    this.initialClipId,
    this.initialActive = true,
    this.isEdit = false,
  });

  final TeamType initialTeam;
  final List<MediaAsset> clips;
  final String initialName;
  final String initialJerseyNumber;
  final String initialPosition;
  final String? initialClipId;
  final bool initialActive;
  final bool isEdit;

  @override
  State<_AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<_AddPlayerDialog> {
  late final TextEditingController _playerNameController;
  late final TextEditingController _jerseyNumberController;
  late final TextEditingController _positionController;
  late final TextEditingController _clipSearchController;
  late TeamType _teamType;
  late bool _isActive;
  String? _selectedClipId;

  @override
  void initState() {
    super.initState();
    _playerNameController = TextEditingController(text: widget.initialName);
    _jerseyNumberController = TextEditingController(text: widget.initialJerseyNumber);
    _positionController = TextEditingController(text: widget.initialPosition);
    _clipSearchController = TextEditingController();
    _teamType = widget.initialTeam;
    _isActive = widget.initialActive;
    _selectedClipId = widget.initialClipId;
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _jerseyNumberController.dispose();
    _positionController.dispose();
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
      title: Text(widget.isEdit ? 'Spieler bearbeiten' : 'Spieler hinzufügen'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _playerNameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _jerseyNumberController,
                      decoration: const InputDecoration(labelText: 'Trikotnummer'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _positionController,
                      decoration: const InputDecoration(labelText: 'Position'),
                    ),
                  ),
                ],
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
                  setState(() => _teamType = value);
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
                decoration: const InputDecoration(labelText: 'Intro-Clip'),
                items: [
                  const DropdownMenuItem<String>(value: '', child: Text('— Kein Clip —')),
                  ...filteredClips.map(
                    (clip) => DropdownMenuItem(
                      value: clip.id,
                      child: Text('${clip.title} · ${clip.category.name}'),
                    ),
                  ),
                ],
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () {
            final player = _playerNameController.text.trim();
            if (player.isEmpty) return;
            Navigator.of(context).pop(
              _AddPlayerDialogResult(
                playerName: player,
                jerseyNumber: _jerseyNumberController.text.trim(),
                position: _positionController.text.trim(),
                mediaAssetId: _selectedClipId ?? '',
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
