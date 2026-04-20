# Teil 3: Live-Logik, Offline/Sync, Logging und Playback

Dieser Teil darf erst begonnen werden, wenn Teil 2 vollstaendig abgeschlossen und verifiziert ist.

## Szenenlogik

- Eine Szene besteht aus einem oder mehreren Clips.

- Jeder SceneClip braucht Regeln fuer Reihenfolge, Schutzstatus, Ueberspielbarkeit, Prioritaet, playOnce, repeatable, Rotationsgruppe, Unterbrechungsregel und Rueckkehrverhalten.

- Szenenkategorien:

  - Vor dem Spiel

  - Waehrend des Spiels

  - Pause

  - Sonderaktion

  - Nach dem Spiel

  - zusaetzlich benutzerdefinierte Kategorien

## Queue-Logik

- Queue ist eine automatische Abspielreihenfolge oder Schleife.

- Szene kann in Loop laufen.

- aktuelle Szene kann pausiert werden.

- Sonderaktion kann aktuelle Szene unterbrechen.

- danach Rueckkehr zur alten Szene an exakter Stelle.

- Queue live bearbeitbar.

- naechster Clip sichtbar.

- Clip ueberspringen moeglich.

- Szenewechsel moeglich.

## Schutzlogik

- geschuetzte Clips duerfen nicht von allen Aktionen unterbrochen werden.

- nur bestimmte Quick Actions duerfen geschuetzte Clips unterbrechen.

## Unterbrechungsarten

- sofort unterbrechen

- nach aktuellem Clip unterbrechen

- nicht erlaubt

## Automatische Rotation

- Varianten einer Aktion muessen zuerst vollstaendig durchlaufen.

- Wiederholungen erst danach.

- direkte Doppelung vermeiden, wenn moeglich.

## Quick Actions

- Vor dem Spiel

- Spielbeginn

- Pause

- Nach dem Spiel

- Einlauf Heim

- Einlauf Gegner

- 2 Minuten Heim

- 2 Minuten Gegner

- Timeout Heim

- Timeout Gegner

- rote Karte

- Wischer

- Tor Heim

- Tor Gegner

- Verletzung Heim

- Verletzung Gegner

## Spielerlogik

- Spieler fuer Einlauf, Tor und Verletzung nutzbar machen

- Side-Panel-Ansicht suchbar und scrollbar

- Heim und Gegner getrennt

## Logging

Loggen:

- Live-Aktionen

- Fehler

- Queue-Wechsel

- Unterbrechungen

- Rueckkehr

- Sync-Konflikte

- Systemwarnungen

- VLC-Fehler

## Offline-First

- App vollstaendig offline nutzbar

- lokale Datenhaltung

- lokaler Medienstatus

- Projektdaten lokal verfuegbar

- Haupt-PC voll offline arbeitsfaehig

## Sync

- spaetere Online-Synchronisation vorbereiten

- Sync-Status je Projekt, Medium und Geraet

- letzter Sync

- Konflikterkennung

- Haupt-PC gewinnt bei Konflikten

- Nebengeraete werden angepasst

- Architektur vorbereiten, auch wenn noch kein finaler Server aktiv ist

## Playback-Architektur

- PlaybackService Interface

- MockPlaybackService

- PlaybackState

- Fehlerzustaende

- Statusmodell

- Anbindung an Live-Control-Logik

- noch keine echte VLC-Endintegration noetig, aber klare spaetere Schnittstelle

## VLC-Vorbereitung

- start clip

- pause

- resume

- stop

- next clip

- load scene

- status abfragen

- fehlerstatus

## Wichtige Architekturregeln

- saubere Controller- und State-Logik

- gut testbare Architektur

- Mock-Playback-State

- keine direkte VLC-Logik in Widgets

- TODOs fuer spaetere Remote- und VLC-Anbindung sinnvoll markieren
