# Fertigstellungs-Check (Projektbezogen)

Zweck:

- Diese Datei ist eine kompakte Orientierung fuer den Abschluss.

- Sie hilft, offene Punkte sichtbar zu machen, ist aber keine starre Pflichtkette.

## 1. Scope und Vollstaendigkeit

- Ist die Nutzeranfrage vollstaendig umgesetzt (nicht nur teilweise)?

- Sind alle genannten Anforderungen aus dem Prompt abgedeckt?

- Gibt es offene TODOs oder Platzhalter, die den Abschluss verhindern?

## 2. Fachliche Sicherheit (LED Live-Betrieb)

- Queue/Fallback/Sponsor-Lock bleiben konsistent.

- Hotkeys loesen keine doppelten oder widerspruechlichen Aktionen aus.

- Intro-/Cue-Trigger sind nur mit gueltigen Projektzuweisungen aktiv.

## 3. Datenintegritaet (Isar)

- Keine stillen Datenverluste durch Modell-/Schema-Aenderungen.

- Fehlerpfade bleiben robust (App bleibt startbar bei DB-Problemen).

- Mapping/Storage wurden bei Domain-Aenderungen mitgeprueft.

## 4. UI und Sprache

- Sichtbare Texte sind kurz, klar, deutsch und mit echten Umlauten (`Ã¤/Ã¶/Ã¼/ÃŸ`).

- Dialoge/Popups sind zentriert und viewport-sicher.

- Keine Kontrast-/Lesbarkeits-Regressions.

## 5. Verifikation

- Relevante Aenderungen: `flutter analyze` wurde ausgefuehrt.

- Bei Logik-Aenderungen: `flutter test` wurde ausgefuehrt.

- Bei Desktop-Flow-Aenderungen: Windows-Smoke-Test (`flutter run -d windows`) soweit lokal moeglich.

- Wenn etwas nicht ausfuehrbar war: Grund transparent dokumentiert.

## 6. Doku und Logs

- Aenderung in passendem Log eingetragen:

  - Feature/Refactor/Infra/Docs -> `.github/commit-change-log.md`

  - Bugfix/Regression -> `.github/bug-fix-log.md`

- Nutzerkorrekturen in `tasks/lessons.md` erfasst.
