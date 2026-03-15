import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/core/theme/app_colors.dart';
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
              description: 'Spieler-Intro mit Reihenfolge, Team-Tabs und direkter Trigger-Steuerung.',
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
                    itemCount: _controller.selectedEntries.length,
                    onReorder: _controller.reorderSelectedTeam,
                    itemBuilder: (_, index) {
                      final entry = _controller.selectedEntries[index];
                      return Padding(
                        key: ValueKey(entry.id),
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: PlayerIntroCard(
                          entry: entry,
                          orderIndex: index,
                          onDelete: () => _controller.deletePlayer(entry.id),
                          onToggleActive: (value) => _controller.togglePlayerActive(entry, value),
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
      title: 'IntroSequenceController',
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
                  Text('playerName: ${activePlayer?.playerName ?? '-'}'),
                  Text('cueId: ${activePlayer?.introCueId ?? '-'}'),
                  Text('orderIndex: ${activePlayer?.sortOrder ?? '-'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 82,
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
            height: 82,
            width: double.infinity,
            child: LargeActionButton(
              label: 'Vorheriger Spieler',
              icon: Icons.skip_previous_rounded,
              onPressed: _controller.playPreviousPlayer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 82,
            width: double.infinity,
            child: LargeActionButton(
              label: 'Nächster Spieler',
              icon: Icons.skip_next_rounded,
              onPressed: _controller.playNextPlayer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 82,
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
    final playerNameController = TextEditingController();
    final cueIdController = TextEditingController();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Spieler hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: playerNameController,
                decoration: const InputDecoration(labelText: 'playerName'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: cueIdController,
                decoration: const InputDecoration(labelText: 'cueId'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) {
      return;
    }

    final playerName = playerNameController.text.trim();
    final cueId = cueIdController.text.trim();
    if (playerName.isEmpty || cueId.isEmpty) {
      return;
    }

    await _controller.addPlayer(playerName: playerName, cueId: cueId);
  }
}

class LineupScreen extends IntroPlayersScreen {
  const LineupScreen({super.key});
}
