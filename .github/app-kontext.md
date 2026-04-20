# App Kontext - LED Management Software

## Produktziel

Die LED Management Software ist eine Desktop-first Flutter-App fuer Live-Regie und LED-Banden-Steuerung bei Handballproduktionen.

## Kernmodule (MVP)

- Projekte verwalten und aktives Projekt setzen.

- Medienbibliothek fuer Clips/Assets inkl. Cue-Typen.

- Live-Control mit Queue, Fallback und Sponsor-Lock.

- Intro-Player fuer Heim-/Gastaufstellungen.

- Dashboard mit Betriebsstatus und Setup-Hinweisen.

- Settings fuer Operator- und Playback-Verhalten.

## Technischer Stack

- Flutter/Dart (Desktop-first, Web-kompatibler Einstieg).

- Lokale Persistenz mit Isar (`isar`, `isar_flutter_libs`).

- Globale Hotkeys mit `hotkey_manager`.

- Dateiauswahl via `file_picker`.

## Relevante Projektbereiche

- App-Code: `led-managementsoftware.archive/lib/`

- Tests: `led-managementsoftware.archive/test/`

- Konfiguration: `led-managementsoftware.archive/pubspec.yaml`, `led-managementsoftware.archive/analysis_options.yaml`

- Plattformen: `led-managementsoftware.archive/windows/`, `led-managementsoftware.archive/web/`

## Persistenz und Sicherheit

- Isar wird in `main.dart` vor `runApp` initialisiert.

- Bei DB- oder Hotkey-Init-Fehlern bleibt die App startbar; Fehler werden geloggt.

- Datenmodell basiert auf lokalen Records mit Payload-JSON und Metadaten (`createdAt`, `updatedAt`, `externalId`).

- Schema-/Migrationsaenderungen duerfen keine bestehenden Projektdaten still verlieren.

## Aktuelle Arbeitskonventionen

- `.github`-Dokumente dienen als Orientierung und koennen je nach Aufgabe gezielt genutzt werden.

- Feature/Refactor/Infra/Docs in `commit-change-log.md` eintragen (eine Zeile).

- Bugfixes in `bug-fix-log.md` eintragen (eine Zeile, mit Ursache/Fix).

- Nutzerkorrekturen in `tasks/lessons.md` als Guardrail festhalten.

## Qualitaetsfokus

- Live-Steuerung muss stabil bleiben (Queue, Fallback, Hotkeys, Intro-Slots).

- Keine stillen Regressionen in Isar-Persistenz und Projektzuweisungen.

- UI auf Desktop und kleinere Viewports robust, klar und deutsch halten.
