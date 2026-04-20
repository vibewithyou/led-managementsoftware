# Teil 4: Supabase-Backend, Konfiguration und Migrationen

Dieser Teil darf erst begonnen werden, wenn Teil 3 vollstaendig abgeschlossen und verifiziert ist.

## Online-Backend

Supabase wird genutzt fuer:

- Projektsynchronisation

- Geraeteprofile

- Logging

- spaetere Remote-Steuerung

- Medien-Metadaten

- spaetere Benutzer- und Geraete-Synchronisation

## Grundsatz

- Die App bleibt vollstaendig offline-first.

- Supabase ist Sync- und Backend-Ebene, nicht Voraussetzung fuer die Kernfunktion.

## Supabase-Anforderungen

- Supabase sauber per CLI integrieren

- lokales Supabase-Konfigurationsverzeichnis anlegen

- Migrationsstruktur vorbereiten

- Tabellen, Policies und Basisstruktur produktionsnah anlegen

- Flutter-App so aufbauen, dass Supabase sauber gekapselt ist

- keine Supabase-Aufrufe quer durch Widgets oder Business-Logik

- Repositories und Services verwenden

- sensible Konfigurationswerte aus `.env` oder sicherer Konfiguration laden

- keine Secrets hart in Widgets oder Business-Logik schreiben

## CLI-Aufgaben

- `supabase init`

- `supabase link --project-ref rtmynyvgnlgpxhimqlis`

- Migrationsstruktur anlegen

- benoetigte SQL-Migrationen erzeugen

- Backend-Struktur fuer die LED-Management-Software vorbereiten

## Flutter-Seite

- offizielles Supabase Flutter SDK nutzen

- zentrale Initialisierung im App-Start

- BackendConfig-Layer

- RemoteDataSources getrennt von LocalDataSources

- Repository-Schicht fuer Projekte, Medien, Szenen, Geraete und Logs

- Fehlerbehandlung sauber

- Mock-Fallback fuer Offlinebetrieb

- SyncService vorbereiten

## Konfigurationsstrategie

- `.env` oder gleichwertige lokale Konfiguration

- zentrale Config-Klasse

- `SUPABASE_URL`

- `SUPABASE_ANON_OR_PUBLISHABLE_KEY`

- optionale Backend-Flags

- bei fehlender Konfiguration klare Fehlermeldung, aber App mit Mock-/Offline-Fallback startbar halten

## Tabellen fuer SQL-Migrationen

1. projects

2. teams

3. players

4. media_categories

5. media_items

6. scenes

7. scene_clips

8. device_profiles

9. live_log_entries

## Datenbankanforderungen

- created_at und updated_at Felder

- sinnvolle Foreign Keys

- Indizes fuer haeufige Abfragen

- soft-delete oder Archivstatus, wo sinnvoll

- Konflikt- und Sync-relevante Felder vorbereiten

- updated_at Trigger

- konsistente Namensgebung

- spaetere Erweiterungen beruecksichtigen

## Haupt-PC-Prioritaet

- Haupt-PC-Prioritaet in Datenstruktur und Sync-Architektur mitdenken

## Wichtige Trennung

- CLI-Setup, Migrationen und Flutter-Integration sauber trennen

- keine unsichere Hardcodierung sensibler Werte im App-Code
