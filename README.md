# LED Management Software

Desktop-first Flutter MVP für Live-Regie und LED-Banden-Steuerung.

## MVP-Stand (aktuell)

Der MVP deckt aktuell folgende Kernflows ab:

- **Projekte verwalten** und aktives Projekt setzen.
- **Clips importieren** (inkl. Metadaten/Cue-Typ) und in der Medienbibliothek prüfen.
- **Live-Steuerung** mit Queue, Fallback, Sponsor-Lock und globalen Hotkeys.
- **Intro-Player-Steuerung** für Heim/Gast-Aufstellungen.
- **Dashboard** mit Live-KPIs, Warnungen und Setup-Hinweisen.
- **Settings** mit produktionsnahen Operator-/Playback-Optionen (lokal persistiert).

## Lokale Persistenz (Isar)

Die App nutzt jetzt Isar als lokale Datenbank (Windows/Desktop kompatibel).

### Initialisierung

- DB-Start erfolgt in [lib/main.dart](lib/main.dart) vor `runApp`.
- Zentrale DB-Instanz: [lib/data/local/isar/isar_database.dart](lib/data/local/isar/isar_database.dart).
- Migrationsstruktur: [lib/data/local/isar/migrations/isar_migration_registry.dart](lib/data/local/isar/migrations/isar_migration_registry.dart).

### Gespeicherte Datenstrukturen

- `MediaAssets` → `IsarMediaAssetRecord` in [lib/data/local/isar/collections/isar_media_asset_record.dart](lib/data/local/isar/collections/isar_media_asset_record.dart)
- `Cues` → `IsarCueRecord` in [lib/data/local/isar/collections/isar_cue_record.dart](lib/data/local/isar/collections/isar_cue_record.dart)
- `Projects` → `IsarProjectRecord` in [lib/data/local/isar/collections/isar_project_record.dart](lib/data/local/isar/collections/isar_project_record.dart)
- `LineupEntries` → `IsarLineupEntryRecord` in [lib/data/local/isar/collections/isar_lineup_entry_record.dart](lib/data/local/isar/collections/isar_lineup_entry_record.dart)
- `EventLogs` → `IsarEventLogRecord` in [lib/data/local/isar/collections/isar_event_log_record.dart](lib/data/local/isar/collections/isar_event_log_record.dart)

Alle Records speichern derzeit Domain-Objekte als JSON-Payload (`payloadJson`) plus technische Metadaten (`createdAt`, `updatedAt`, `externalId`).

### Repository-Implementierungen

- Media Library: [lib/data/repositories/media_library_repository_impl.dart](lib/data/repositories/media_library_repository_impl.dart)
- Media Repository: [lib/data/repositories/media_repository_impl.dart](lib/data/repositories/media_repository_impl.dart)
- Cue Repository: [lib/data/repositories/cue_repository_impl.dart](lib/data/repositories/cue_repository_impl.dart)
- Project Repository: [lib/data/repositories/project_repository_impl.dart](lib/data/repositories/project_repository_impl.dart)
- Lineup Repository: [lib/data/repositories/lineup_repository_impl.dart](lib/data/repositories/lineup_repository_impl.dart)
- Live Log Repository: [lib/data/repositories/live_log_repository_impl.dart](lib/data/repositories/live_log_repository_impl.dart)

### Fehlerbehandlung

- DB-Initialisierung und Repository-Zugriffe sind mit try/catch abgesichert.
- Bei DB-Fehlern bleibt die App startbar; Fehler werden geloggt.

### Migrationen vorbereiten

- Aktuelle Schema-Version wird über `IsarMetaRecord` gehalten.
- Migration-Schritte sind versioniert in `_steps` der Migration Registry vorbereitbar.
