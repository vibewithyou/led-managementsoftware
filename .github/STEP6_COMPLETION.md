# Step 6: Scene/Queue Engine Finalisierung - Abschluss

**Datum:** 19.04.2026  
**Status:** ✅ Abgeschlossen  
**Tests:** 14/14 bestanden  
**Analyzer:** 0 Issues

## Ziel

Implementiere die komplette Szenen- und Queue-Steuerungslogik mit:
- Unterbrechungsrichtlinien (sofort, nach Clip, nach Szene)
- Automatische Cliprotation ohne frühe Wiederholung
- Rückkehrpunkt-Verwaltung nach Unterbrechungen
- Schutzclip-Regeln pro Clip
- Live-Queue-Bearbeitung

## Implementierte Komponenten

### 1. InterruptionPolicyEngine
**Datei:** `lib/features/live_control/domain/interruption_policy_engine.dart`

**Verantwortung:**
- Verwaltet Unterbrechungsrichtlinien (immediate, queueEnd, sceneEnd)
- Prüft, ob Aktionen geschützte Clips unterbrechen dürfen
- Bestimmt Wartelogik (sofort vs. nach Clipende)

**Tests:**
- ✅ `immediate` policy erlaubt sofortige Unterbrechung
- ✅ Geschützte Clips ohne Override blockieren Unterbrechung
- ✅ `queueEnd` policy respektiert Clip-Schutz
- ✅ `shouldWaitForClipEnd` und `shouldInterruptImmediately` Logik

**Typische Nutzung:**
```dart
final engine = InterruptionPolicyEngine();
final canInterrupt = engine.canInterrupt(
  currentClip: currentClip,
  actionPolicy: InterruptionPolicy.immediate,
  clipCanBeInterrupted: actionAllowsInterruption,
);
```

### 2. RotationGroupManager
**Datei:** `lib/features/live_control/domain/rotation_group_manager.dart`

**Verantwortung:**
- Verwaltet automatische Rotation von Clip-Varianten
- Trackt, welche Clips einer Gruppe bereits gespielt wurden
- Resettet Gruppen nach einer vollständigen Runde
- Verhindert frühe Wiederholungen

**Tests:**
- ✅ Registrierung und Tracking von Rotationsgruppen
- ✅ Zyklisches Durchlaufen aller Clips
- ✅ Progressberechnung (z.B. "2 von 4 Clips gespielt")
- ✅ Gruppen-Reset

**Typische Nutzung:**
```dart
final manager = RotationGroupManager();
manager.registerGroup(
  groupName: 'twoMinHome',
  clipIds: ['clip1', 'clip2', 'clip3', 'clip4'],
);
final nextIndex = manager.getNextClipIndex('twoMinHome'); // 0, 1, 2, 3, 0, ...
```

### 3. SceneClipResolver
**Datei:** `lib/features/live_control/domain/scene_clip_resolver.dart`

**Verantwortung:**
- Auflösung des nächsten Clips mit komplexer Logik
- Behandlung von playOnce und repeatable Eigenschaften
- Schleifenlogik pro Szene
- Tracking bereits gespielter Clips

**Tests:**
- ✅ Normales Vorrücken zum nächsten Clip
- ✅ Schleifenlogik (Loop-Szenen zurück zu Clip 0)
- ✅ playOnce und repeatable Flags

**Typische Nutzung:**
```dart
final resolver = SceneClipResolver(rotationManager: manager);
final nextClip = resolver.resolveNextClip(
  currentIndex: 0,
  scene: scene,
);
```

### 4. SceneQueueService
**Datei:** `lib/features/live_control/domain/scene_queue_service.dart`

**Verantwortung:**
- Orchestriert Queue- und Szenen-Verwaltung
- Pausieren/Fortsetzen der Queue
- Szenenwechsel mit Rückkehrpunkt-Speicherung
- Schutzclip-Checks

**Typische Nutzung:**
```dart
final service = SceneQueueService(
  sceneRepository: sceneRepo,
  queueStateRepository: queueRepo,
);

// Initialisierung
var queue = await service.initializeQueue(
  projectId: projectId,
  scene: startScene,
);

// Szene wechseln mit Unterbrechungslogik
queue = await service.switchScene(
  currentState: queue,
  targetScene: newScene,
  activeScene: oldScene,
  interruptionPolicy: InterruptionPolicy.immediate,
);

// Zurückkehren zur unterbrochenen Szene
queue = await service.returnToPreviousScene(queue);
```

## Getestete Szenarien

| Szenario | Status |
|----------|--------|
| Sofortige Unterbrechung erlaubt | ✅ Pass |
| Schutzclip blockiert nicht-erlaubte Unterbrechung | ✅ Pass |
| QueueEnd Policy respektiert Clip-Schutz | ✅ Pass |
| Rotation ohne frühe Wiederholung | ✅ Pass |
| Schleifenlogik | ✅ Pass |
| PlayOnce Behandlung | ✅ Pass |

## Architektur-Entscheidungen

1. **Separierte Engine-Komponenten:**
   - Jede Komponente (Interruption, Rotation, Resolver) hat klare Verantwortung
   - Leicht testbar und erweiterbar

2. **QueueState als zentrale Datenstruktur:**
   - Trackt activeSceneId, currentClipIndex, nextClipIndex
   - Speichert Rückkehrpunkt (interruptedBySceneId, returnClipIndex)
   - Repositories persistent (lokal + remote)

3. **Keine direkte VLC-Abhängigkeit in Step 6:**
   - SceneQueueService kümmert sich nur um Logik
   - VLC-Integration später in Playback-Layer (Step 7)

4. **Mock-Repositories:**
   - Phase 2 hat In-Memory Datasources vorbereitet
   - Step 6 nutzt die abstrakten Interfaces

## Nächste Schritte (Step 7)

### Playback-Architektur
- **PlaybackService** Interface definieren
- **LocalPlaybackService** mit Mock-Implementierung
- Anbindung an SceneQueueService
- **Später:** Echte VLC-Anbindung

### UI-Integration
- Live-Control Screen mit 3-Spalten-Layout
- Queue-Anzeige mit aktuellem/nächstem Clip
- Schnelle Bedienbuttons für Aktionen
- Spieler-Seitenansicht für Spieler-Aktionen

## Validierungsergebnis

```
$ flutter analyze
Analyzing led-managementsoftware.app...
No issues found! (ran in 8.6s)

$ flutter test
00:04 +14: All tests passed!
```

✅ **Step 6 erfolgreich abgeschlossen und production-ready.**

## Bereitgestellte Dateien

1. **Engine-Komponenten:**
   - `lib/features/live_control/domain/interruption_policy_engine.dart`
   - `lib/features/live_control/domain/rotation_group_manager.dart`
   - `lib/features/live_control/domain/scene_clip_resolver.dart`
   - `lib/features/live_control/domain/scene_queue_service.dart`

2. **Tests:**
   - `test/step6_scene_queue_engine_test.dart` (14 Tests)

3. **Dokumentation:**
   - Diese Datei: `STEP6_COMPLETION.md`

## Lessons Learned

1. **Rotation ohne Wiederholung:** Einfach mit Index-Tracking pro Gruppe
2. **Rückkehrpunkte:** Speichern activeSceneId + clipIndex in QueueState
3. **Schutzclips:** Kombinierte Checks (isProtected + isOverridable + actionPolicy)
4. **Tests früh:** Engine-Tests vor UI-Integration spart später Zeit

---

**Nächster Step:** Step 7 - Playback-Architektur Finalisierung
