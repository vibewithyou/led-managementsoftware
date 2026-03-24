import 'package:flutter/foundation.dart';
import 'package:led_management_software/data/repositories/lineup_repository_impl.dart';
import 'package:led_management_software/data/repositories/media_repository_impl.dart';
import 'package:led_management_software/data/services/playback_service.dart';
import 'package:led_management_software/domain/entities/cue.dart';
import 'package:led_management_software/domain/entities/lineup_entry.dart';
import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/enums/cue_trigger_mode.dart';
import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/queue_behavior.dart';
import 'package:led_management_software/domain/enums/team_type.dart';
import 'package:led_management_software/domain/repositories/lineup_repository.dart';
import 'package:led_management_software/domain/repositories/media_repository.dart';
import 'package:led_management_software/features/intro_players/controller/intro_sequence_controller.dart';
import 'package:led_management_software/features/intro_players/model/intro_lineup_item_model.dart';
import 'package:led_management_software/shared/state/active_project_state.dart';

class IntroPlayersController extends ChangeNotifier {
  IntroPlayersController({LineupRepository? repository, MediaRepository? mediaRepository})
      : _repository = repository ?? LineupRepositoryImpl(),
        _mediaRepository = mediaRepository ?? MediaRepositoryImpl() {
    _sequenceController.addListener(_onSequenceChanged);
    _activeProjectState.addListener(_onActiveProjectChanged);
  }

  final LineupRepository _repository;
  final MediaRepository _mediaRepository;
  final ActiveProjectState _activeProjectState = ActiveProjectState.instance;
  final IntroSequenceController _sequenceController = IntroSequenceController();

  List<LineupEntry> _homeEntries = const [];
  List<LineupEntry> _guestEntries = const [];
  List<MediaAsset> _availableClips = const [];
  Map<String, MediaAsset> _clipById = const {};
  TeamType _selectedTeam = TeamType.home;
  bool _isLoading = true;
  String? _error;
  PlaybackService? _playbackService;

  List<LineupEntry> get homeEntries => _homeEntries;
  List<LineupEntry> get guestEntries => _guestEntries;
  List<LineupEntry> get selectedEntries => _selectedTeam == TeamType.home ? _homeEntries : _guestEntries;
  List<MediaAsset> get availableClips => _availableClips;
  TeamType get selectedTeam => _selectedTeam;
  bool get isLoading => _isLoading;
  String? get error => _error;
  IntroSequenceController get sequenceController => _sequenceController;
  String get projectLabel => _activeProjectState.activeProject?.name ?? 'Kein aktives Projekt';

  List<IntroLineupItemModel> get selectedItems {
    return selectedEntries
        .map((entry) => IntroLineupItemModel(entry: entry, mediaAsset: _clipById[entry.introCueId]))
        .toList(growable: false);
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final activeProject = _activeProjectState.activeProject;
    if (activeProject == null) {
      _homeEntries = const [];
      _guestEntries = const [];
      _availableClips = const [];
      _clipById = const {};
      _isLoading = false;
      _error = 'Kein aktives Projekt ausgewählt.';
      notifyListeners();
      return;
    }

    try {
      _availableClips = await _mediaRepository.getAllMediaAssets();
      _clipById = {
        for (final asset in _availableClips.where((item) => item.isActive)) asset.id: asset,
      };

      _homeEntries = await _repository.getLineupForTeam(
        projectId: activeProject.id,
        teamType: TeamType.home,
      );
      _guestEntries = await _repository.getLineupForTeam(
        projectId: activeProject.id,
        teamType: TeamType.guest,
      );
      _sortLocal();
      _ensurePlaybackService();
    } catch (exception) {
      _error = exception.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTeam(TeamType teamType) {
    _selectedTeam = teamType;
    notifyListeners();
  }

  Future<void> addPlayer({
    required String playerName,
    required String mediaAssetId,
    required TeamType teamType,
    required bool isActive,
  }) async {
    final project = _activeProjectState.activeProject;
    if (project == null) return;

    final now = DateTime.now();
    final teamEntries = teamType == TeamType.home ? _homeEntries : _guestEntries;

    final newEntry = LineupEntry(
      id: 'lineup_${now.microsecondsSinceEpoch}',
      projectId: project.id,
      playerName: playerName,
      jerseyNumber: '',
      position: '',
      teamType: teamType,
      introCueId: mediaAssetId,
      sortOrder: teamEntries.length,
      isCaptain: false,
      isActive: isActive,
    );

    await _repository.saveLineupEntry(newEntry);
    await load();
  }

  Future<void> deletePlayer(String entryId) async {
    await _repository.deleteLineupEntry(entryId);
    await load();
  }

  Future<void> togglePlayerActive(LineupEntry entry, bool isActive) async {
    await _repository.saveLineupEntry(entry.copyWith(isActive: isActive));
    await load();
  }

  Future<void> reorderSelectedTeam(int oldIndex, int newIndex) async {
    final project = _activeProjectState.activeProject;
    if (project == null) return;

    final current = [...selectedEntries];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final moved = current.removeAt(oldIndex);
    current.insert(newIndex, moved);

    final orderedIds = current.map((entry) => entry.id).toList(growable: false);
    await _repository.reorderLineup(
      projectId: project.id,
      teamType: _selectedTeam,
      entryIdsInOrder: orderedIds,
    );
    await load();
  }

  void startIntro() {
    final sequence = _buildSequenceEntries(selectedEntries);
    _sequenceController.startIntro(sequence);
    _playActiveSequenceEntry(trigger: 'intro_start');
  }

  void playNextPlayer() {
    final sequence = _buildSequenceEntries(selectedEntries);
    _sequenceController.playNextPlayer(sequence);
    _playActiveSequenceEntry(trigger: 'intro_next');
  }

  void playPreviousPlayer() {
    final sequence = _buildSequenceEntries(selectedEntries);
    _sequenceController.playPreviousPlayer(sequence);
    _playActiveSequenceEntry(trigger: 'intro_previous');
  }

  void skipCurrentPlayer() {
    final sequence = _buildSequenceEntries(selectedEntries);
    _sequenceController.skipCurrentPlayer(sequence);
    _playActiveSequenceEntry(trigger: 'intro_skip');
  }

  void playEndClip() {
    _sequenceController.playEndClip();
    _playbackService?.returnToFallback(triggerSource: 'intro_endclip');
  }

  List<IntroSequenceEntry> _buildSequenceEntries(List<LineupEntry> entries) {
    return entries
        .map(
          (entry) {
            final clip = _clipById[entry.introCueId];
            return IntroSequenceEntry(
              id: entry.id,
              playerName: entry.playerName,
              mediaAssetId: clip?.id,
              clipTitle: clip?.title ?? 'Clip fehlt',
              category: clip?.category.name ?? '-',
              sortOrder: entry.sortOrder,
              isActive: entry.isActive,
              hasValidClip: clip != null,
            );
          },
        )
        .toList(growable: false);
  }

  void _playActiveSequenceEntry({required String trigger}) {
    final activeEntry = _sequenceController.activePlayer;
    if (activeEntry == null || activeEntry.mediaAssetId == null) {
      return;
    }

    final cue = Cue(
      id: 'intro_${DateTime.now().microsecondsSinceEpoch}',
      mediaAssetId: activeEntry.mediaAssetId!,
      title: activeEntry.clipTitle,
      cueType: CueType.oneShot,
      isLocked: false,
      canInterrupt: true,
      mustPlayToEnd: false,
      autoReturnToFallback: false,
      queueIfBlocked: true,
      queueBehavior: QueueBehavior.enqueue,
      triggerMode: CueTriggerMode.manual,
      hotkey: null,
      isFavorite: false,
      notes: 'Spielerintro ${activeEntry.playerName}',
    );

    _playbackService?.startCue(cue, triggerSource: trigger);
  }

  void _ensurePlaybackService() {
    final project = _activeProjectState.activeProject;
    if (project == null) {
      _playbackService?.dispose();
      _playbackService = null;
      return;
    }

    _playbackService?.dispose();

    final fallbackAsset = _clipById[project.fallbackCueId];
    final fallbackCue = Cue(
      id: 'intro_fallback_${project.id}',
      mediaAssetId: fallbackAsset?.id ?? '',
      title: fallbackAsset?.title ?? 'Fallback Intro',
      cueType: CueType.loop,
      isLocked: false,
      canInterrupt: true,
      mustPlayToEnd: false,
      autoReturnToFallback: true,
      queueIfBlocked: true,
      queueBehavior: QueueBehavior.enqueue,
      triggerMode: CueTriggerMode.manual,
      hotkey: null,
      isFavorite: false,
      notes: null,
    );

    final durations = <String, int>{
      for (final clip in _availableClips) clip.id: clip.durationMs,
    };

    _playbackService = PlaybackService(
      projectId: project.id,
      fallbackCue: fallbackCue,
      cueDurationsMs: durations,
    );
  }

  void _sortLocal() {
    _homeEntries = [..._homeEntries]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _guestEntries = [..._guestEntries]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void _onSequenceChanged() {
    notifyListeners();
  }

  void _onActiveProjectChanged() {
    load();
  }

  @override
  void dispose() {
    _sequenceController.removeListener(_onSequenceChanged);
    _sequenceController.dispose();
    _playbackService?.dispose();
    _activeProjectState.removeListener(_onActiveProjectChanged);
    super.dispose();
  }
}
