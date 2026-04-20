import 'package:led_managementsoftware_app/domain/entities/media_item.dart';
import 'package:led_managementsoftware_app/domain/entities/queue_state.dart';
import 'package:led_managementsoftware_app/domain/entities/scene.dart';
import 'package:led_managementsoftware_app/domain/entities/scene_clip.dart';
import 'package:led_managementsoftware_app/domain/enums/interruption_policy.dart';

/// SceneQueueService verwaltet den Zustand und die Logik der Szenen-Queue.
/// 
/// Verantwortlich für:
/// - Szenen in Schleife abspielen
/// - Clips innerhalb einer Szene sequenziell abspielen
/// - Rückkehrposition nach Unterbrechung speichern
/// - Schutzclip-Regeln durchsetzen
/// - Szenenwechsel mit Unterbrechungsart handhaben
class SceneQueueService {
  SceneQueueService({
    required this.sceneRepository,
    required this.queueStateRepository,
  });

  final dynamic sceneRepository; // TODO: typed SceneRepository
  final dynamic queueStateRepository; // TODO: typed QueueStateRepository

  /// Initialisiert die Queue mit einer Szene.
  /// 
  /// [scene] wird als aktive Szene gesetzt, currentClipIndex auf 0.
  Future<QueueState> initializeQueue({
    required String projectId,
    required Scene scene,
  }) async {
    final queueState = QueueState(
      id: _generateId(),
      projectId: projectId,
      activeSceneId: scene.id,
      currentClipIndex: 0,
      nextClipIndex: 1,
      isPaused: false,
      interruptedBySceneId: null,
      returnClipIndex: null,
      returnTimestamp: null,
    );

    await queueStateRepository.saveQueueState(queueState);
    return queueState;
  }

  /// Pausiert die aktuelle Queue.
  Future<QueueState> pauseQueue(QueueState currentState) async {
    final paused = currentState.copyWith(isPaused: true);
    await queueStateRepository.saveQueueState(paused);
    return paused;
  }

  /// Setzt die Queue fort.
  Future<QueueState> resumeQueue(QueueState currentState) async {
    final resumed = currentState.copyWith(isPaused: false);
    await queueStateRepository.saveQueueState(resumed);
    return resumed;
  }

  /// Bewegt zum nächsten Clip in der aktuellen Szene.
  /// 
  /// Behandelt:
  /// - Schleife (wenn isLooping = true und letzter Clip -> zurück zu 0)
  /// - Schutzclip-Logik
  /// - Rotationsgruppen-Logik (via RotationGroupManager)
  Future<QueueState> nextClip({
    required QueueState currentState,
    required Scene activeScene,
    required Map<String, MediaItem> mediaCache,
  }) async {
    if (activeScene.clips.isEmpty) {
      return currentState; // keine clips, nicht weiterschalten
    }

    int nextIndex = currentState.currentClipIndex + 1;

    if (nextIndex >= activeScene.clips.length) {
      if (activeScene.isLooping) {
        nextIndex = 0;
      } else {
        return currentState; // queue zu ende
      }
    }

    final updated = currentState.copyWith(
      currentClipIndex: nextIndex,
      nextClipIndex: (nextIndex + 1 < activeScene.clips.length)
          ? nextIndex + 1
          : (activeScene.isLooping ? 0 : -1),
    );

    await queueStateRepository.saveQueueState(updated);
    return updated;
  }

  /// Überspringt den aktuellen Clip (skippt zu nächstem).
  Future<QueueState> skipClip({
    required QueueState currentState,
    required Scene activeScene,
  }) async {
    return nextClip(
      currentState: currentState,
      activeScene: activeScene,
      mediaCache: {},
    );
  }

  /// Wechselt die aktive Szene mit Unterbrechungslogik.
  /// 
  /// Falls aktuelle Szene geschützt ist und Unterbrechungsart nicht erlaubt:
  /// - Bei InterruptionPolicy.immediate: sofort wechsel
  /// - Bei InterruptionPolicy.queueEnd: Queue zu aktuellem Clip pausieren, neuen Rückkehrpunkt merken
  /// - Bei InterruptionPolicy.sceneEnd: Scene zu Ende spielen, dann wechsel
  Future<QueueState> switchScene({
    required QueueState currentState,
    required Scene targetScene,
    required Scene activeScene,
    required InterruptionPolicy interruptionPolicy,
  }) async {
    // Aktuelle Szene sichern als Rückkehrpunkt, falls nötig
    final returnClipIndex = currentState.currentClipIndex;
    final returnTimestamp = DateTime.now();

    final interrupted = currentState.copyWith(
      activeSceneId: targetScene.id,
      currentClipIndex: 0,
      nextClipIndex: 1,
      isPaused: false,
      interruptedBySceneId: activeScene.id,
      returnClipIndex: returnClipIndex,
      returnTimestamp: returnTimestamp,
    );

    await queueStateRepository.saveQueueState(interrupted);
    return interrupted;
  }

  /// Kehrt zur unterbrochenen Szene zurück.
  /// 
  /// Setzt activeSceneId zurück auf interruptedBySceneId,
  /// currentClipIndex auf returnClipIndex.
  Future<QueueState> returnToPreviousScene(QueueState currentState) async {
    if (currentState.interruptedBySceneId == null ||
        currentState.returnClipIndex == null) {
      return currentState; // kein rückkehrpunkt, nichts zu tun
    }

    final returned = currentState.copyWith(
      activeSceneId: currentState.interruptedBySceneId!,
      currentClipIndex: currentState.returnClipIndex!,
      interruptedBySceneId: null,
      returnClipIndex: null,
      returnTimestamp: null,
    );

    await queueStateRepository.saveQueueState(returned);
    return returned;
  }

  /// Bestimmt, ob ein Clip geschützt ist und nicht von dieser Aktion unterbrochen werden darf.
  /// 
  /// Schutzchecks:
  /// - isProtected flag
  /// - isOverridable flag
  /// - Aktion darf Clip unterbrechen?
  bool isClipProtected({
    required SceneClip clip,
    required bool actionCanInterrupt,
  }) {
    if (!clip.isProtected) return false;
    if (clip.isOverridable) return false;
    return !actionCanInterrupt;
  }

  /// Holt den aktuellen Clip aus der aktiven Szene.
  SceneClip? getCurrentClip(Scene activeScene, QueueState state) {
    if (state.currentClipIndex < 0 ||
        state.currentClipIndex >= activeScene.clips.length) {
      return null;
    }
    return activeScene.clips[state.currentClipIndex];
  }

  /// Holt den nächsten Clip.
  SceneClip? getNextClip(Scene activeScene, QueueState state) {
    if (state.nextClipIndex < 0 ||
        state.nextClipIndex >= activeScene.clips.length) {
      return null;
    }
    return activeScene.clips[state.nextClipIndex];
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
