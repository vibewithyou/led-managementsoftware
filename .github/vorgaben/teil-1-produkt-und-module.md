# Teil 1: Produkt, Module und Arbeitsoberflaechen

Dieser Teil ist zuerst vollstaendig abzuschliessen, bevor Teil 2 begonnen werden darf.

## Produktziel

- Die LED Management Software plant LED-Banden, Szenen und Live-Ablaufe fuer ein Spiel oder Event.

- Ein Projekt entspricht immer genau einem Spiel oder Event.

- Die App wird neu, sauber und modular aufgebaut; das alte Projekt dient nur als fachliche Referenz.

## Plattformen

- Flutter fuer Windows, iOS, Android, Web, macOS und Linux.

- Startprioritaet: Windows und iOS.

## Grundprinzipien

- offline-first

- spaeter Cloud- und Sync-Unterstuetzung

- Haupt-PC hat immer Vorrang

- grosse, schnelle Live-Bedienung

- Fokus auf Szenen und Presets statt Timeline

- VLC laeuft als Wiedergabeinstanz im Hintergrund

- modernes, minimalistisches, professionelles Dark-UI

- einklappbare Sidebar mit Icons

- Feature-First-Struktur

- wartbarer, sauberer, modularer Code

## Geraete- und Prioritaetsmodell

- Haupt-PC ist mit LED-Bande verbunden, steuert VLC und gewinnt bei Konflikten immer.

- Nebengeraete duerfen vorbereiten, bearbeiten und spaeter fernsteuern.

- Konflikte werden zugunsten des Haupt-PCs aufgeloest.

## Hauptmodule

1. Dashboard

2. Projekte

3. Mediathek

4. Szenen und Queue-Logik

5. Live-Steuerung

6. Einstellungen

7. Offline und Sync

8. Playback und VLC

9. Logging

10. Supabase-Backend-Anbindung

## Hauptnavigation

- Linke Sidebar, einklappbar

- Hauptpunkte: Dashboard, Projekte, Mediathek, Live-Steuerung, Einstellungen

## Dashboard

Zeigt:

- naechstes Projekt

- aktives Projekt

- Warnungen

- VLC-Status

- Online/Offline

- letzter Sync

- Medienverfuegbarkeit

- Schnellaktionen

## Projekte

Interne Unterbereiche:

- Uebersicht

- Stammdaten

- Medien

- Szenen

- Teams und Spieler

- Projekt-Check

## Mediathek

- zentrale Medienverwaltung

- Suche, Filter, Kategorien, Vorschau und Metadaten

## Live-Steuerung

- wichtigster Screen

- 3-Spalten-Layout

- links: Heim-Aktionen

- mitte: Hauptsteuerung, aktiver Clip, naechster Clip, Status

- rechts: Gegner-Aktionen und Queue-/Live-Zustand

- grosse Buttons und Kacheln

## Einstellungen

Bereiche:

- Allgemein

- Wiedergabe/VLC

- Live-Regeln

- Sync

- Speicher

- Logging

- Backend/Supabase-Diagnose

## Design

- dark UI

- modern, minimalistisch, professionell

- grosse Kacheln und Buttons

- klare visuelle Hierarchie

- Farben:

  - Rot = kritisch

  - Gelb = Warnung

  - Gruen = aktiv

  - Blau = Standard

  - Grau = neutral
