import 'package:led_managementsoftware_app/domain/entities/scene.dart';
import 'package:led_managementsoftware_app/domain/entities/scene_clip.dart';
import 'package:led_managementsoftware_app/features/live_control/domain/rotation_group_manager.dart';

/// SceneClipResolver verwaltet die Auflösung des nächsten Clips mit Rotationslogik.
/// 
/// Verantwortlich für:
/// - Bestimmung des nächsten Clips unter Berücksichtigung von Rotationsgruppen
/// - Behandlung von playOnce und repeatable
/// - Schutzstatus-Checks
class SceneClipResolver {
  SceneClipResolver({required this.rotationManager});

  final RotationGroupManager rotationManager;

  /// Holt den nächsten Clip basierend auf aktuellen Index und Rotationsgruppe.
  /// 
  /// Parameter:
  /// - [currentIndex]: aktueller Clip-Index in der Szene
  /// - [scene]: aktive Szene mit allen Clips
  /// 
  /// Logik:
  /// 1. Berechne nextIndex = currentIndex + 1
  /// 2. Wenn rotationGroup definiert: nutze RotationGroupManager
  /// 3. Wenn playOnce: skippe, wenn schon gespielt
  /// 4. Wenn nicht repeatable: skippe nach spielen
  SceneClip? resolveNextClip({
    required int currentIndex,
    required Scene scene,
  }) {
    if (scene.clips.isEmpty) return null;

    int nextIndex = currentIndex + 1;

    // Schleife: wenn am Ende, zurück zu 0
    if (nextIndex >= scene.clips.length) {
      if (scene.isLooping) {
        nextIndex = 0;
      } else {
        return null; // keine nächster clip
      }
    }

    final nextClip = scene.clips[nextIndex];

    // Wenn playOnce gesetzt: check, ob schon gespielt
    if (nextClip.playOnce && hasClipBeenPlayed(nextClip.id)) {
      // überspringe zu nächstem
      return resolveNextClip(currentIndex: nextIndex, scene: scene);
    }

    return nextClip;
  }

  /// Markiert einen Clip als gespielt (für playOnce).
  void markClipAsPlayed(String clipId) {
    _playedClipIds.add(clipId);
  }

  /// Prüft, ob ein Clip bereits gespielt wurde.
  bool hasClipBeenPlayed(String clipId) {
    return _playedClipIds.contains(clipId);
  }

  /// Reset aller gespielten Clips (z.B. Szenen-Wechsel oder Projekt-Ende).
  void resetPlayedClips() {
    _playedClipIds.clear();
  }

  /// Interner Cache der bereits gespielten Clip-IDs (für playOnce).
  final Set<String> _playedClipIds = {};

  /// Holt alle Clips einer Rotationsgruppe.
  List<SceneClip> getClipsInRotationGroup({
    required Scene scene,
    required String groupName,
  }) {
    return scene.clips
        .where((clip) => clip.rotationGroup == groupName)
        .toList();
  }

  /// Bestimmt, ob ein Clip übersprungen werden soll (basierend auf repeatable).
  bool shouldSkipClip(SceneClip clip, bool hasBeenPlayed) {
    if (clip.playOnce && hasBeenPlayed) return true;
    if (!clip.repeatable && hasBeenPlayed) return true;
    return false;
  }
}
