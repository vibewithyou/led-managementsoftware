import 'package:flutter/foundation.dart';
import 'package:led_management_software/data/local/isar/isar_database.dart';
import 'package:led_management_software/data/repositories/lineup_repository_impl.dart';
import 'package:led_management_software/data/repositories/live_log_repository_impl.dart';
import 'package:led_management_software/data/repositories/media_repository_impl.dart';
import 'package:led_management_software/data/repositories/project_repository_impl.dart';
import 'package:led_management_software/domain/entities/live_event_log.dart';
import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/entities/project.dart';
import 'package:led_management_software/domain/enums/transport_status.dart';
import 'package:led_management_software/shared/widgets/surfaces/status_badge.dart';
import 'package:led_management_software/shared/state/active_project_state.dart';
import 'package:led_management_software/shared/state/live_runtime_state.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    ProjectRepositoryImpl? projectRepository,
    MediaRepositoryImpl? mediaRepository,
    LiveLogRepositoryImpl? liveLogRepository,
    LineupRepositoryImpl? lineupRepository,
  })  : _projectRepository = projectRepository ?? ProjectRepositoryImpl(),
        _mediaRepository = mediaRepository ?? MediaRepositoryImpl(),
        _liveLogRepository = liveLogRepository ?? LiveLogRepositoryImpl(),
        _lineupRepository = lineupRepository ?? LineupRepositoryImpl() {
    _activeProjectState.addListener(_onStateChanged);
    _liveRuntimeState.addListener(_onStateChanged);
    load();
  }

  final ProjectRepositoryImpl _projectRepository;
  final MediaRepositoryImpl _mediaRepository;
  final LiveLogRepositoryImpl _liveLogRepository;
  final LineupRepositoryImpl _lineupRepository;
  final ActiveProjectState _activeProjectState = ActiveProjectState.instance;
  final LiveRuntimeState _liveRuntimeState = LiveRuntimeState.instance;

  bool _isLoading = true;
  String? _error;
  List<String> _alerts = const [];
  List<Project> _projects = const [];
  Project? _activeProject;
  List<DashboardReadinessCheck> _readinessChecks = const [];
  String _activeProjectLabel = 'Kein aktives Projekt';
  String _currentCueLabel = 'Keine aktive Wiedergabe';
  String _lastActionLabel = 'Noch keine Aktionen';
  String _fallbackLabel = 'Nicht konfiguriert';
  String _sponsorLoopLabel = 'Nicht konfiguriert';
  String _transportMessage = 'Kein aktiver Transportstatus';
  TransportStatus _transportStatus = TransportStatus.stopped;
  bool _isLiveReady = false;
  bool _filesMissing = false;
  List<String> _queuedCueLabels = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Project> get projects => _projects;
  Project? get activeProject => _activeProject;
  List<String> get alerts => _alerts;
  List<DashboardReadinessCheck> get readinessChecks => _readinessChecks;
  String get activeProjectLabel => _activeProjectLabel;
  String get currentCueLabel => _currentCueLabel;
  String get lastActionLabel => _lastActionLabel;
  String get fallbackLabel => _fallbackLabel;
  String get sponsorLoopLabel => _sponsorLoopLabel;
  String get transportMessage => _transportMessage;
  TransportStatus get transportStatus => _transportStatus;
  bool get isLiveReady => _isLiveReady;
  bool get filesMissing => _filesMissing;
  List<String> get queuedCueLabels => _queuedCueLabels;
  bool get hasActiveProject => _activeProjectState.activeProject != null;

  Future<void> switchActiveProject(String projectId) async {
    if (_activeProject?.id == projectId) {
      return;
    }

    await _projectRepository.setActiveProject(projectId);
    final nextProject = _projects.where((item) => item.id == projectId).cast<Project?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );
    _activeProjectState.setActiveProject(nextProject);
    await load();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await _projectRepository.getAllProjects();
      final activeProject = _activeProjectState.activeProject ??
          _projects.where((item) => item.isActive).cast<Project?>().firstWhere((item) => item != null, orElse: () => null) ??
          await _projectRepository.getActiveProject();
      _activeProject = activeProject;

      final mediaAssets = await _mediaRepository.getAllMediaAssets();
      final activeClips = mediaAssets.where((item) => item.isActive).toList(growable: false);
      final assetById = {for (final item in activeClips) item.id: item};
      final configuredSlots = activeProject?.configuredCueCount ?? 0;
      final requiredSlots = activeProject?.requiredCueCount ?? ProjectCueSlot.values.length;
      final setupComplete = activeProject?.isConfigurationComplete ?? false;
      final fallbackSet = _hasCueValue(activeProject?.fallbackCueId);
      final sponsorLoopSet = _hasCueValue(activeProject?.sponsorLoopCueId);
      final missingSlots = _missingSlots(activeProject);

      final logs = await _liveLogRepository.getLogsForProject(activeProject?.id ?? 'live_project');
      final lastLog = logs.isNotEmpty ? logs.last : null;

      final queue = _liveRuntimeState.queue;
      final transportStatus = _liveRuntimeState.playbackState.transportStatus;
      final transportMessage = _liveRuntimeState.playbackState.transportMessage;
      _transportStatus = transportStatus;
      _transportMessage = transportMessage;
      _queuedCueLabels = queue.map((item) => item.title).toList(growable: false);
      _currentCueLabel = _liveRuntimeState.playbackState.currentCue?.title ?? 'Keine aktive Wiedergabe';
      _lastActionLabel = _buildActionLabel(lastLog);

      _activeProjectLabel = activeProject?.name ?? 'Kein aktives Projekt';
      _fallbackLabel = _resolveCueTitle(assetById, activeProject?.fallbackCueId) ?? 'Nicht konfiguriert';
      _sponsorLoopLabel = _resolveCueTitle(assetById, activeProject?.sponsorLoopCueId) ?? 'Nicht konfiguriert';

      int lineupCount = 0;
      int invalidLineupReferences = 0;
      if (activeProject != null) {
        final lineup = await _lineupRepository.getLineupForProject(activeProject.id);
        lineupCount = lineup.length;
        final activeIds = activeClips.map((item) => item.id).toSet();
        invalidLineupReferences = lineup.where((entry) => entry.introCueId != null && !activeIds.contains(entry.introCueId)).length;
      }

      final requiredSpecialClips = ProjectCueSlot.values.where((slot) => !slot.isCoreClip).length;
      final configuredSpecialClips = activeProject?.configuredSpecialClipCount ?? 0;
      final lineupReady = lineupCount > 0 && invalidLineupReferences == 0;
      final specialClipsReady = configuredSpecialClips == requiredSpecialClips;
      _filesMissing = invalidLineupReferences > 0 || transportStatus == TransportStatus.fileMissing;

      _readinessChecks = [
        DashboardReadinessCheck(
          label: 'Projekt-Setup',
          detail: '$configuredSlots/$requiredSlots Slots belegt',
          isHealthy: setupComplete,
          badgeType: setupComplete ? StatusBadgeType.ready : StatusBadgeType.queued,
        ),
        DashboardReadinessCheck(
          label: 'Sponsor Loop',
          detail: _sponsorLoopLabel,
          isHealthy: sponsorLoopSet,
          badgeType: sponsorLoopSet ? StatusBadgeType.ready : StatusBadgeType.error,
        ),
        DashboardReadinessCheck(
          label: 'Fallback',
          detail: _fallbackLabel,
          isHealthy: fallbackSet,
          badgeType: fallbackSet ? StatusBadgeType.ready : StatusBadgeType.error,
        ),
        DashboardReadinessCheck(
          label: 'Spielerliste',
          detail: invalidLineupReferences > 0
              ? '$invalidLineupReferences Clip-Referenzen fehlen'
              : lineupCount == 0
                  ? 'Keine Intro-Spieler definiert'
                  : '$lineupCount Spieler bereit',
          isHealthy: lineupReady,
          badgeType: lineupReady ? StatusBadgeType.ready : StatusBadgeType.queued,
        ),
        DashboardReadinessCheck(
          label: 'Sonderclips',
          detail: '$configuredSpecialClips/$requiredSpecialClips gesetzt',
          isHealthy: specialClipsReady,
          badgeType: specialClipsReady ? StatusBadgeType.ready : StatusBadgeType.queued,
        ),
        DashboardReadinessCheck(
          label: 'Dateistatus',
          detail: _filesMissing ? 'Fehlende Referenzen erkannt' : 'Keine fehlenden Dateien erkannt',
          isHealthy: !_filesMissing,
          badgeType: _filesMissing ? StatusBadgeType.error : StatusBadgeType.ready,
        ),
      ];

      final transportHealthy = transportStatus != TransportStatus.error && transportStatus != TransportStatus.fileMissing;
      _isLiveReady = activeProject != null && setupComplete && fallbackSet && sponsorLoopSet && lineupReady && specialClipsReady && transportHealthy;

      final warningItems = <String>[];
      if (IsarDatabase.instance.initializationError != null) {
        warningItems.add('Lokale Datenbank konnte nicht vollständig initialisiert werden. Neustart empfohlen.');
      }
      if (activeProject == null) {
        warningItems.add('Kein aktives Projekt gesetzt. Bitte in „Projekte“ ein Event aktivieren.');
      }
      if (!fallbackSet) {
        warningItems.add('Kein Fallback-Cue für das aktive Projekt definiert.');
      }
      if (!sponsorLoopSet) {
        warningItems.add('Kein Sponsor-Loop-Cue für das aktive Projekt definiert.');
      }
      if (missingSlots.isNotEmpty) {
        final preview = missingSlots.take(3).map((item) => item.label).join(', ');
        final remainder = missingSlots.length > 3 ? ' (+${missingSlots.length - 3} weitere)' : '';
        warningItems.add('Projekt-Setup unvollständig: $preview$remainder.');
      }
      if (invalidLineupReferences > 0) {
        warningItems.add('$invalidLineupReferences Intro-Einträge verweisen auf fehlende Clips.');
      }
      if (transportStatus == TransportStatus.error || transportStatus == TransportStatus.fileMissing) {
        warningItems.add('Playback-Transportfehler: $transportMessage');
      }
      _alerts = _sortedWarnings(warningItems);
    } catch (exception) {
      _error = 'Dashboard-Daten konnten nicht geladen werden: $exception';
      _projects = const [];
      _activeProject = null;
      _readinessChecks = const [];
      _alerts = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> _sortedWarnings(List<String> warnings) {
    final sorted = [...warnings];
    sorted.sort((a, b) => _warningPriority(a).compareTo(_warningPriority(b)));
    return sorted;
  }

  int _warningPriority(String warning) {
    final normalized = warning.toLowerCase();
    if (normalized.contains('transportfehler') || normalized.contains('fehlend') || normalized.contains('datenbank')) {
      return 0;
    }
    return 1;
  }

  String _buildActionLabel(LiveEventLog? log) {
    if (log == null) {
      return 'Noch keine Aktionen';
    }

    final actionLabel = switch (log.actionType.name) {
      'triggerCue' => 'Cue gestartet',
      'stopCue' => 'Cue gestoppt',
      'queueAdd' => 'Zur Queue hinzugefügt',
      'queueRemove' => 'Aus Queue gestartet',
      'queueClear' => 'Queue geleert',
      'blackScreenOn' => 'Black Screen',
      _ => log.actionType.name,
    };

    return '$actionLabel • ${_formatTime(log.timestamp ?? DateTime.now())}';
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String? _resolveCueTitle(Map<String, MediaAsset> assetById, String? cueId) {
    if (cueId == null || cueId.isEmpty) {
      return null;
    }
    final asset = assetById[cueId];
    return asset?.title;
  }

  bool _hasCueValue(String? cueId) {
    return cueId != null && cueId.trim().isNotEmpty;
  }

  List<ProjectCueSlot> _missingSlots(Project? project) {
    if (project == null) {
      return const [];
    }

    return ProjectCueSlot.values.where((slot) {
      final cueId = project.cueIdForSlot(slot);
      return !_hasCueValue(cueId);
    }).toList(growable: false);
  }

  void _onStateChanged() {
    load();
  }

  @override
  void dispose() {
    _activeProjectState.removeListener(_onStateChanged);
    _liveRuntimeState.removeListener(_onStateChanged);
    super.dispose();
  }
}

class DashboardReadinessCheck {
  const DashboardReadinessCheck({
    required this.label,
    required this.detail,
    required this.isHealthy,
    required this.badgeType,
  });

  final String label;
  final String detail;
  final bool isHealthy;
  final StatusBadgeType badgeType;
}
