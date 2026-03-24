import 'package:flutter/foundation.dart';
import 'package:led_management_software/data/local/isar/isar_database.dart';
import 'package:led_management_software/data/repositories/lineup_repository_impl.dart';
import 'package:led_management_software/data/repositories/live_log_repository_impl.dart';
import 'package:led_management_software/data/repositories/media_repository_impl.dart';
import 'package:led_management_software/data/repositories/project_repository_impl.dart';
import 'package:led_management_software/domain/entities/live_event_log.dart';
import 'package:led_management_software/domain/entities/media_asset.dart';
import 'package:led_management_software/domain/enums/media_category.dart';
import 'package:led_management_software/domain/enums/transport_status.dart';
import 'package:led_management_software/features/dashboard/model/dashboard_kpi_model.dart';
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
  List<DashboardKpiModel> _kpis = const [];
  List<String> _alerts = const [];
  String _activeProjectLabel = 'Kein aktives Projekt';
  String _currentCueLabel = 'Keine aktive Wiedergabe';
  String _lastActionLabel = 'Noch keine Aktionen';
  String _fallbackLabel = 'Nicht konfiguriert';
  List<String> _queuedCueLabels = const [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DashboardKpiModel> get kpis => _kpis;
  List<String> get alerts => _alerts;
  String get activeProjectLabel => _activeProjectLabel;
  String get currentCueLabel => _currentCueLabel;
  String get lastActionLabel => _lastActionLabel;
  String get fallbackLabel => _fallbackLabel;
  List<String> get queuedCueLabels => _queuedCueLabels;
  bool get hasActiveProject => _activeProjectState.activeProject != null;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final activeProject = _activeProjectState.activeProject ?? await _projectRepository.getActiveProject();
      final mediaAssets = await _mediaRepository.getAllMediaAssets();
      final activeClips = mediaAssets.where((item) => item.isActive).toList(growable: false);
      final assetById = {for (final item in activeClips) item.id: item};
      final sponsorClips = activeClips.where((item) => item.category == MediaCategory.sponsor).length;
      final playerClips = activeClips.where((item) => item.category == MediaCategory.player).length;
      final fallbackSet = activeProject?.fallbackCueId != null && activeProject!.fallbackCueId!.isNotEmpty;
      final sponsorLoopSet = activeProject?.sponsorLoopCueId != null && activeProject!.sponsorLoopCueId!.isNotEmpty;

      final logs = await _liveLogRepository.getLogsForProject(activeProject?.id ?? 'live_project');
      final lastLog = logs.isNotEmpty ? logs.last : null;

      final queue = _liveRuntimeState.queue;
      final transportStatus = _liveRuntimeState.playbackState.transportStatus;
      final transportMessage = _liveRuntimeState.playbackState.transportMessage;
      _queuedCueLabels = queue.map((item) => item.title).toList(growable: false);
      _currentCueLabel = _liveRuntimeState.playbackState.currentCue?.title ?? 'Keine aktive Wiedergabe';
      _lastActionLabel = _buildActionLabel(lastLog);

      _activeProjectLabel = activeProject?.name ?? 'Kein aktives Projekt';
      _fallbackLabel = _resolveCueTitle(assetById, activeProject?.fallbackCueId) ?? 'Nicht konfiguriert';

      int invalidLineupReferences = 0;
      if (activeProject != null) {
        final lineup = await _lineupRepository.getLineupForProject(activeProject.id);
        final activeIds = activeClips.map((item) => item.id).toSet();
        invalidLineupReferences = lineup.where((entry) => entry.introCueId != null && !activeIds.contains(entry.introCueId)).length;
      }

      _kpis = [
        DashboardKpiModel(label: 'Aktive Clips', value: '${activeClips.length}', change: 'Mediathek', positive: true),
        DashboardKpiModel(label: 'Sponsorclips', value: '$sponsorClips', change: sponsorLoopSet ? 'Loop gesetzt' : 'Loop fehlt', positive: sponsorLoopSet),
        DashboardKpiModel(label: 'Spielerclips', value: '$playerClips', change: 'Für Intro verfügbar', positive: playerClips > 0),
        DashboardKpiModel(label: 'Fallback', value: fallbackSet ? 'Gesetzt' : 'Fehlt', change: _fallbackLabel, positive: fallbackSet),
        DashboardKpiModel(
          label: 'VLC-Transport',
          value: transportStatus.name,
          change: transportMessage,
          positive: transportStatus != TransportStatus.error && transportStatus != TransportStatus.fileMissing,
        ),
        DashboardKpiModel(label: 'Queue', value: '${queue.length}', change: queue.isEmpty ? 'Leer' : 'Ausstehend', positive: true),
        DashboardKpiModel(label: 'Now Playing', value: _currentCueLabel, change: 'Live-Wiedergabe', positive: _currentCueLabel != 'Keine aktive Wiedergabe'),
        DashboardKpiModel(label: 'Letzte Aktion', value: _lastActionLabel, change: 'Live-Protokoll', positive: lastLog != null),
      ];

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
      if (invalidLineupReferences > 0) {
        warningItems.add('$invalidLineupReferences Intro-Einträge verweisen auf fehlende Clips.');
      }
      if (transportStatus == TransportStatus.error || transportStatus == TransportStatus.fileMissing) {
        warningItems.add('Playback-Transportfehler: $transportMessage');
      }
      _alerts = warningItems;
    } catch (exception) {
      _error = 'Dashboard-Daten konnten nicht geladen werden: $exception';
      _kpis = const [];
      _alerts = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
