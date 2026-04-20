# Teil 2: Architektur, Datenmodell und Screen-Umsetzung

Dieser Teil darf erst begonnen werden, wenn Teil 1 vollstaendig abgeschlossen und verifiziert ist.

## Feature-First-Architektur

Hauptbereiche:

- core

- shared

- features

## core

Enthaelt:

- app

- routing

- theme

- constants

- config

- error handling

- shared services interfaces

## shared

Enthaelt:

- wiederverwendbare Widgets

- Buttons

- Cards

- Panels

- Dialoge

- Statusbadges

- Tabellen

- Form-Komponenten

- Layout-Helfer

## features

Features:

- dashboard

- projects

- media_library

- scenes

- live_control

- settings

- sync

- playback

- logging

Pro Feature moeglichst gegliedert in:

- data

- domain

- presentation

- application oder controller

## Zusaetzlich

- sauberes Routing

- AppShell mit einklappbarer Sidebar

- dunkles Theme

- Demo-Daten

- Struktur so vorbereiten, dass weitere Logik sauber ergaenzt werden kann

## Benoetigte Entitaeten

- Project

- Team

- Player

- MediaItem

- MediaCategory

- Scene

- SceneClip

- QueueState

- QuickAction

- LiveLogEntry

- DeviceProfile

## Anforderungen an die Modelle

- saubere Dart-Modelle

- sinnvolle Enums

- Domain und Data klar trennen

- auf lokale Speicherung und spaeteren Sync vorbereiten

- CopyWith, Equality, Serialisierung und Helpers implementieren

## Pflichtfelder

Project:

- id, name, date, location, status, homeTeam, awayTeam, notes, createdAt, updatedAt, archivedAt

Team:

- id, name, side

Player:

- id, projectId, teamSide, name, number, linkedClipIds, enabledForIntro, enabledForGoal, enabledForInjury

MediaItem:

- id, name, localPath, remotePath, type, categoryId, tags, duration, isActive, syncStatus, checksum, createdAt, updatedAt

MediaCategory:

- id, name, isSystemCategory

Scene:

- id, projectId, name, category, isLooping, isActive, isDefault, fallbackSceneId, createdAt, updatedAt

SceneClip:

- id, sceneId, mediaItemId, orderIndex, isProtected, isOverridable, priority, playOnce, repeatable, rotationGroup, interruptionPolicy, returnBehavior

QueueState:

- id, projectId, activeSceneId, currentClipIndex, nextClipIndex, isPaused, interruptedBySceneId, returnClipIndex, returnTimestamp

QuickAction:

- id, name, type, targetSide, linkedSceneId, startsImmediately, canInterruptProtectedClip, requiresConfirmation, isEnabled

LiveLogEntry:

- id, projectId, timestamp, deviceId, actorName, action, details, success

DeviceProfile:

- id, name, type, isOnline, lastSyncAt

## Screen-Umsetzung

- alle Hauptscreens als moderne Desktop-/Tablet-UI umsetzen

- keine halbfertigen Platzhalterlayouts

- saubere Widgets und sinnvolle Subwidgets

- responsive Verhalten fuer Desktop und Tablet

- Mockdaten integrieren, damit Screens direkt testbar sind

## Dashboard-UI

- naechstes Projekt

- aktives Projekt

- Warnungen

- VLC-Status

- Online/Offline

- letzter Sync

- Medienstatus

- Schnellaktionen

## Projekte-UI

Unterseiten oder Tabs:

- Uebersicht

- Stammdaten

- Medien

- Szenen

- Teams und Spieler

- Projekt-Check

## Mediathek-UI

- Kategorienleiste

- Suche

- Filter

- Medienliste oder Grid

- Vorschau

- Metadaten-Panel

## Live-Steuerung-UI

- 3-Spalten-Layout

- grosse Quick-Actions links und rechts

- mittlere Hauptsteuerung mit aktivem Clip, naechstem Clip, Status und Steuerbuttons

- Spieler-Auswahl als Side Panel mit Suchfeld und Scrollliste

- Status-Badges fuer Schutzclip, Online/Offline, VLC und Warnungen

## Einstellungen-UI

Bereiche:

- Allgemein

- Wiedergabe

- Live-Regeln

- Sync

- Speicher

- Logging
