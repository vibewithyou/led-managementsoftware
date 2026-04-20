# LED Management Software AI Kurz-Instructions

## Kontext-Check (optional)

immer lesen:

1. `.github/app-kontext.md`

2. `.github/problem.md`

3. `.github/fertigstellungs-check.md`

4. `.github/led-managementsoftware-vorgaben-index.md`

Hinweis:

- Nach Aenderungen Logs pflegen:

  - Feature/Refactor/Infra/Docs -> `commit-change-log.md`

  - Bugfix/Regression -> `bug-fix-log.md`

  - Beide Logs nur im Kurzformat pflegen: pro Eintrag genau eine Zeile.

## Kern-Workflow

- Nicht-triviale Aufgaben immer mit kurzer Spezifikation bearbeiten: Scope, Annahmen, Risiken, Tests.

- Erst read-only verstehen, dann umsetzen, dann verifizieren.

- Subagents aktiv fuer Recherche und Parallelanalyse nutzen.

- Nutzerkorrekturen in `tasks/lessons.md` festhalten.

- Keine Fertigmeldung ohne Evidenz aus Build, Test, Logs oder reproduzierbarem Check.

- Root Cause beheben, keine rein kosmetischen Workarounds.

## Projekt-Guardrails

- Projektfokus: Flutter-/Dart-App fuer LED-Regie und Clip-Steuerung (`led-managementsoftware.archive`).

- Relevante Bereiche: `lib/`, `test/`, `windows/`, `web/`, `pubspec.yaml`, `analysis_options.yaml`.

- Kleine, fokussierte Diffs; keine unnoetigen Format-Aenderungen.

- Build-/Generator-Artefakte nicht manuell bearbeiten (`build/`, `windows/flutter/ephemeral/`).

- Lokale Persistenz (Isar) robust halten: kein stiller Datenverlust bei Migrationen/Schema-Aenderungen.

- Live-Control-Sicherheit beachten: Queue/Fallback/Hotkeys duerfen durch UI- oder Datenaenderungen nicht inkonsistent werden.

## Verifikation

- Nach relevanten Codeaenderungen mindestens `flutter analyze` ausfuehren.

- Bei Logik-Aenderungen zusaetzlich `flutter test` ausfuehren.

- Bei Desktop-Flow-Aenderungen Windows-Smoke-Test ausfuehren (`flutter run -d windows`), sofern lokal moeglich.

## UI-Guardrails

- Sichtbare UI-Texte kurz, klar und deutsch; echte Umlaute (`Ã¤/Ã¶/Ã¼/ÃŸ`) verwenden.

- Keine Darkmode-Regressions mit unlesbaren Flaechen.

- Dialoge/Popups zentriert, viewport-sicher und auf Desktop wie Mobile robust halten.

- `.github/problem.md` vor jeder UI-Aenderung aktiv als Anti-Regression-Check nutzen.
