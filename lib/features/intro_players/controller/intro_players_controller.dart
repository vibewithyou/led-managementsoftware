import 'package:flutter/foundation.dart';
import 'package:led_management_software/data/repositories/lineup_repository_impl.dart';
import 'package:led_management_software/domain/entities/lineup_entry.dart';
import 'package:led_management_software/domain/enums/team_type.dart';
import 'package:led_management_software/domain/repositories/lineup_repository.dart';
import 'package:led_management_software/features/intro_players/controller/intro_sequence_controller.dart';
import 'package:led_management_software/shared/state/active_project_state.dart';

class IntroPlayersController extends ChangeNotifier {
  IntroPlayersController({LineupRepository? repository}) : _repository = repository ?? LineupRepositoryImpl() {
    _sequenceController.addListener(_onSequenceChanged);
  }

  final LineupRepository _repository;
  final ActiveProjectState _activeProjectState = ActiveProjectState.instance;
  final IntroSequenceController _sequenceController = IntroSequenceController();

  List<LineupEntry> _homeEntries = const [];
  List<LineupEntry> _guestEntries = const [];
  TeamType _selectedTeam = TeamType.home;
  bool _isLoading = true;
  String? _error;

  List<LineupEntry> get homeEntries => _homeEntries;
  List<LineupEntry> get guestEntries => _guestEntries;
  List<LineupEntry> get selectedEntries => _selectedTeam == TeamType.home ? _homeEntries : _guestEntries;
  TeamType get selectedTeam => _selectedTeam;
  bool get isLoading => _isLoading;
  String? get error => _error;
  IntroSequenceController get sequenceController => _sequenceController;
  String get projectLabel => _activeProjectState.activeProject?.name ?? 'Kein aktives Projekt';

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final activeProject = _activeProjectState.activeProject;
    if (activeProject == null) {
      _homeEntries = const [];
      _guestEntries = const [];
      _isLoading = false;
      _error = 'Kein aktives Projekt ausgewählt.';
      notifyListeners();
      return;
    }

    try {
      _homeEntries = await _repository.getLineupForTeam(
        projectId: activeProject.id,
        teamType: TeamType.home,
      );
      _guestEntries = await _repository.getLineupForTeam(
        projectId: activeProject.id,
        teamType: TeamType.guest,
      );
      _sortLocal();
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

  Future<void> addPlayer({required String playerName, required String cueId}) async {
    final project = _activeProjectState.activeProject;
    if (project == null) {
      return;
    }

    final entries = selectedEntries;
    final now = DateTime.now();
    final newEntry = LineupEntry(
      id: 'lineup_${now.microsecondsSinceEpoch}',
      projectId: project.id,
      playerName: playerName,
      jerseyNumber: '',
      position: '',
      teamType: _selectedTeam,
      introCueId: cueId,
      sortOrder: entries.length,
      isCaptain: false,
      isActive: true,
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
    if (project == null) {
      return;
    }

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
    _sequenceController.startIntro(selectedEntries);
  }

  void playNextPlayer() {
    _sequenceController.playNextPlayer(selectedEntries);
  }

  void playPreviousPlayer() {
    _sequenceController.playPreviousPlayer(selectedEntries);
  }

  void playEndClip() {
    _sequenceController.playEndClip();
  }

  void _sortLocal() {
    _homeEntries = [..._homeEntries]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _guestEntries = [..._guestEntries]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void _onSequenceChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _sequenceController.removeListener(_onSequenceChanged);
    _sequenceController.dispose();
    super.dispose();
  }
}
