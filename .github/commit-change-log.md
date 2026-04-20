# Commit Change Log

Kurzformat:

- Datum | Bereich | Typ | Kurzfassung | Verifikation

- Pro Eintrag genau eine Zeile.

## Eintraege

- 2026-04-18 | .github | docs | Pflicht-Preload-Dateien auf LED Management Software zugeschnitten und HikeTrack-fremde Inhalte entfernt | Verifiziert: manueller Review von `.github/copilot-instructions.md`, `.github/commit-change-log.md`, `.github/bug-fix-log.md`, `.github/app-kontext.md`, `.github/problem.md`

- 2026-04-18 | led-managementsoftware.app | feat | Neues Flutter-Projekt in `.app` als Mehrplattform-Basis (android/ios/linux/macos/web/windows) erstellt | Verifiziert: `flutter analyze` in `led-managementsoftware.app`

- 2026-04-19 | .github | docs | Projektbezogene Fertigstellungs-Checkdatei eingefuehrt und in Pflicht-Preload plus Abschlussregeln verankert | Verifiziert: manueller Review von `.github/fertigstellungs-check.md` und `.github/copilot-instructions.md`

- 2026-04-19 | .github | docs | Verbindliche Projektvorgaben-Datei aufgenommen und als Pflicht-Leseschritt in Preload plus Fertigstellungs-Check verankert | Verifiziert: manueller Review von `.github/led-managementsoftware-vorgaben.txt`, `.github/copilot-instructions.md`, `.github/fertigstellungs-check.md`

- 2026-04-19 | .github | docs | Abschlusslogik um Mindestgrenze von 10 aktiven Pruefdurchlaeufen erweitert; Fertig nur ohne offene Punkte aus Vorgaben-TXT | Verifiziert: manueller Review von `.github/copilot-instructions.md` und `.github/fertigstellungs-check.md`

- 2026-04-19 | .github | docs | Vorgaben in vier feste Teildateien mit Index zerlegt; Bearbeitung jetzt strikt sequenziell pro Teil | Verifiziert: manueller Review von `.github/led-managementsoftware-vorgaben-index.md`, `.github/vorgaben/`, `.github/fertigstellungs-check.md`, `.github/copilot-instructions.md`

- 2026-04-19 | led-managementsoftware.app | feat | Teil 1 umgesetzt: Feature-First-Shell, Dark-Theme, Sidebar und fünf Hauptscreens mit Modulübersicht in `.app` aufgebaut | Verifiziert: `flutter analyze` und `flutter test` in `led-managementsoftware.app`

- 2026-04-19 | .github | docs | Verbindlichen Arbeitsloop hinterlegt: nach Teilabschluss automatisch naechsten offenen Teil starten, kein Zwischenabschluss erlaubt | Verifiziert: manueller Review von `.github/copilot-instructions.md`, `.github/fertigstellungs-check.md`, `.github/led-managementsoftware-vorgaben-index.md`

- 2026-04-19 | led-managementsoftware.app | feat | Teil 2 umgesetzt: Core/Shared/Feature-Architektur erweitert, Pflicht-Entitaeten+DTOs getrennt modelliert, Projekt-Tabs und Live-Spielerpanel integriert | Verifiziert: `flutter analyze` und `flutter test` in `led-managementsoftware.app`

- 2026-04-19 | led-managementsoftware.app | feat | Teil 3 umgesetzt: Live-Control-Controller mit Queue/Unterbrechung/Rueckkehr/Schutzclip/Rotation sowie Mock-Playback+Sync-Architektur und Logging-/Sync-/Playback-Views integriert | Verifiziert: `flutter analyze` und `flutter test` in `led-managementsoftware.app`

- 2026-04-19 | led-managementsoftware.app | feat | Step 6: Scene/Queue Engine finalisiert mit InterruptionPolicyEngine, RotationGroupManager, SceneClipResolver, SceneQueueService | Verifiziert: `flutter analyze` (0 issues), `flutter test` (14/14 passed)

- 2026-04-19 | led-managementsoftware.app | feat | Teil 4 abgeschlossen: Supabase CLI init+link, Initialmigration (9 Tabellen, Trigger, Indizes, RLS), Backend-Config/Initializer und gekapselte RemoteDataSources+Offline-Repositories fuer Projekte/Medien/Szenen/Geraete/Logs aufgebaut | Verifiziert: `flutter analyze` und `flutter test` in `led-managementsoftware.app` (Supabase-DB-Lint lokal ohne Docker nicht ausfuehrbar)

- 2026-04-19 | led-managementsoftware.app | feat | Supabase-Sync im Live-Control-Flow verdrahtet (Runtime -> Router -> Screen -> Controller -> SupabaseSyncService) mit Offline-Fallback auf Mock nur ohne Runtime | Verifiziert: `flutter analyze` und `flutter test` in `led-managementsoftware.app`

- 2026-04-19 | led-managementsoftware.app | refactor | Produktivpfad ohne Mock-Defaults umgesetzt: LocalPlaybackService aktiv, Dashboard/Playback-Platzhalter entfernt, RepositoryFactory mit OfflineRemote-Fallbacks statt MockRemote | Verifiziert: `flutter analyze`, `flutter test`, `flutter run -d windows --release` in `led-managementsoftware.app`

- 2026-04-19 | led-managementsoftware.app | infra | Supabase-CLI-Abgleich produktiv ausgefuehrt: `supabase db push --linked` auf Projekt `rtmynyvgnlgpxhimqlis`, Migration 20260419012530 remote angewendet | Verifiziert: `supabase migration list` zeigt Local=Remote=20260419012530

- 2026-04-19 | led-managementsoftware.app | docs | Logo/Favicon vereinheitlicht: In-App-Logo aus `web/favicon.png` als Asset `assets/branding/logo.png` eingebunden, `canva-clips` unveraendert belassen | Verifiziert: `flutter analyze` und `flutter test` in `led-managementsoftware.app`

- 2026-04-19 | led-managementsoftware.app | docs | Favicon-Quelle auf Nutzerdatei `C:/Users/PCUser/Downloads/ChatGPT Image 19. Apr. 2026, 20_19_08.png` gesetzt; `canva-clips` bewusst unberuehrt | Verifiziert: SHA256-Hash Quelle=Ziel (`web/favicon.png`)

- 2026-04-19 | .github | docs | Starre Pflichtlektuere/Loop-Regeln entfernt; Kontext- und Vorgaben-Dateien auf optionale Orientierung umgestellt | Verifiziert: manueller Review von `.github/copilot-instructions.md`, `.github/fertigstellungs-check.md`, `.github/led-managementsoftware-vorgaben-index.md`, `.github/app-kontext.md`
