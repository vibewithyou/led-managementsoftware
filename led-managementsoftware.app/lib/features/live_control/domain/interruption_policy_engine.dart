import 'package:led_managementsoftware_app/domain/entities/scene_clip.dart';
import 'package:led_managementsoftware_app/domain/enums/interruption_policy.dart';

/// InterruptionPolicyEngine verwaltet, wie Sonderaktionen eine Szene unterbrechen dürfen.
/// 
/// Unterstützt drei Unterbrechungsarten:
/// - immediate: sofortige Unterbrechung
/// - queueEnd: erst nach aktuellem Clip
/// - sceneEnd: erst nach aktuellem Scene-Ende
/// 
/// Die Engine entscheidet anhand der Clip-Eigenschaften und der Aktion,
/// ob eine Unterbrechung erlaubt ist.
class InterruptionPolicyEngine {
  /// Prüft, ob eine Aktion den aktuellen Clip unterbrechen darf.
  /// 
  /// Parameter:
  /// - [currentClip]: Clip, der gerade läuft
  /// - [actionPolicy]: Unterbrechungsart der Aktion
  /// - [clipCanBeInterrupted]: darf dieser Clip vom aktuellen Clip-Schutz her unterbrochen werden?
  /// 
  /// Rückgabe:
  /// - true: Unterbrechung sofort oder nach Bedingung möglich
  /// - false: Unterbrechung nicht erlaubt
  bool canInterrupt({
    required SceneClip currentClip,
    required InterruptionPolicy actionPolicy,
    required bool clipCanBeInterrupted,
  }) {
    // Wenn Clip geschützt ist und Aktion darf nicht unterbrechen: nein
    if (currentClip.isProtected && !clipCanBeInterrupted) {
      return false;
    }

    // Je nach Unterbrechungsart:
    switch (actionPolicy) {
      case InterruptionPolicy.immediate:
        // sofort unterbrechen, egal was
        return true;
      case InterruptionPolicy.queueEnd:
        // nur, wenn nicht gerade ein Clip läuft oder wenn Clip keine Schutzregeln hat
        return !currentClip.isProtected || currentClip.isOverridable;
      case InterruptionPolicy.sceneEnd:
        // nur am Ende der Szene erlaubt
        return false; // TODO: implementierung in SceneQueueService
    }
  }

  /// Bestimmt, ob die Aktion nach Clipende starten soll.
  bool shouldWaitForClipEnd(InterruptionPolicy policy) {
    return policy == InterruptionPolicy.queueEnd ||
        policy == InterruptionPolicy.sceneEnd;
  }

  /// Bestimmt, ob eine Unterbrechung sofort erfolgt.
  bool shouldInterruptImmediately(InterruptionPolicy policy) {
    return policy == InterruptionPolicy.immediate;
  }

  /// Label für UI-Anzeige der Unterbrechungsart.
  String getPolicyLabel(InterruptionPolicy policy) {
    return policy.label;
  }

  /// Bestimmt für einen Clip die Standard-Unterbrechungsart basierend auf Schutzstatus.
  InterruptionPolicy getDefaultPolicyForClip(SceneClip clip) {
    if (clip.isProtected && !clip.isOverridable) {
      return InterruptionPolicy.sceneEnd; // geschützte Clips erst nach Szenenende
    }
    return InterruptionPolicy.immediate; // alle anderen sofort
  }
}
