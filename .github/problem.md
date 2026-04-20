# LED Management Software Problem Guardrails

Diese Datei beschreibt haeufige Fehler, die bei neuen Aenderungen aktiv vermieden werden muessen. Sie ist vor jeder inhaltlichen Arbeit mitzulesen und bei UI-/Flow-Aenderungen verbindlich anzuwenden.

## 1. Sprache und sichtbare Texte

- Sichtbare UI-Texte kurz, klar und deutsch halten.

- Echte Umlaute verwenden: `Ã¤`, `Ã¶`, `Ã¼`, `ÃŸ`.

- Keine generischen KI-Texte, keine langen Erklaerbloeke in Dialogen.

- Labels und Aktionen eindeutig formulieren (Operator soll in Live-Situationen sofort verstehen, was passiert).

## 2. Live-Control und Betriebssicherheit

- Queue-Logik, Fallback und Sponsor-Lock duerfen durch UI-/State-Aenderungen nicht inkonsistent werden.

- Hotkeys duerfen keine doppelten oder widerspruechlichen Aktionen ausloesen.

- Fehler in Live-Control immer mit klarer Rueckmeldung behandeln; keine stillen Abbrueche.

- Intro-/Cue-Trigger nur ausloesen, wenn die benoetigten Projektzuweisungen vorhanden sind.

## 3. Isar-Persistenz und Datenintegritaet

- Keine stillen Datenverluste bei Schema-/Migrationsaenderungen.

- Bei Aenderungen an Domain-Objekten immer Mapping und Storage-Records mitpruefen.

- Fehlerpfade robust halten: App muss bei lokalen DB-Problemen startbar bleiben.

- Build-/Generator-Artefakte nicht manuell patchen (`build/`, `windows/flutter/ephemeral/`).

## 4. UI, Dialoge und Viewport

- Dialoge/Popups immer zentriert und viewport-sicher.

- Auf kleineren Viewports keine abgeschnittenen Aktionsbuttons und kein horizontaler Overflow.

- Kontrast in hellen und dunklen Flaechen pruefen; keine unlesbaren Textflaechen.

- Kritische Aktionen (z. B. Projektwechsel, Slot-Aenderungen) klar bestaetigen.

## 5. Plattformgrenzen beachten

- Desktop ist Primarziel; Windows-Flows duerfen nicht regressieren.

- Web-Guards (`kIsWeb`) nicht entfernen, wenn Desktop-spezifische Features aktiv sind.

- Globale Hotkeys nur auf unterstuetzten Plattformen initialisieren.

## 6. Qualitaets-Check vor Abschluss

Vor Abschluss jeder relevanten Aenderung aktiv pruefen:

1. Sind sichtbare Texte klar, kurz und deutsch?

2. Bleiben Queue/Fallback/Hotkeys fachlich konsistent?

3. Ist Isar-Persistenz unveraendert robust (kein stiller Datenverlust)?

4. Sind Dialoge zentriert und viewport-sicher?

5. Wurden passende Checks ausgefuehrt (`flutter analyze`, ggf. `flutter test`, ggf. `flutter run -d windows`)?

## 7. Ziel dieser Datei

Diese Guardrails sollen Wiederholungsfehler vermeiden, damit die LED Management Software stabil, bedienbar und live-sicher bleibt.
