# Bug Fix Log

Kurzformat:

- Datum | ID | Symptom -> Ursache -> Fix | Verifikation

- Pro Eintrag genau eine Zeile.

## Eintraege

- 2026-04-19 | BUG-001 | Windows-Start stuerzte mit NotInitializedError in dotenv -> dotenv.maybeGet wurde bei nicht initialisiertem Env ungefangen aufgerufen -> _read gegen ungeinitialisierte dotenv-Zugriffe abgesichert (try/catch) mit sauberem Fallback auf dart-define/offline | Verifiziert: `flutter analyze`, `flutter test`, `flutter run -d windows --release` in `led-managementsoftware.app`
