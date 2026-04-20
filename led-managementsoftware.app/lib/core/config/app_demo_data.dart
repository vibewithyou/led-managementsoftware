import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/routing/app_section.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class ProjectSnapshot {
  const ProjectSnapshot({
    required this.name,
    required this.location,
    required this.matchup,
    required this.dateLabel,
    required this.status,
    required this.note,
  });

  final String name;
  final String location;
  final String matchup;
  final String dateLabel;
  final String status;
  final String note;
}

class AlertSnapshot {
  const AlertSnapshot({
    required this.title,
    required this.message,
    required this.tone,
  });

  final String title;
  final String message;
  final StatusBadgeTone tone;
}

class MetricSnapshot {
  const MetricSnapshot({
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final String label;
  final String value;
  final String detail;
  final Color color;
}

class ModuleSnapshot {
  const ModuleSnapshot({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> items;
}

class MediaClipSnapshot {
  const MediaClipSnapshot({
    required this.name,
    required this.category,
    required this.format,
    required this.length,
    required this.status,
  });

  final String name;
  final String category;
  final String format;
  final String length;
  final String status;
}

class QueueSnapshot {
  const QueueSnapshot({
    required this.title,
    required this.current,
    required this.next,
    required this.protection,
  });

  final String title;
  final String current;
  final String next;
  final String protection;
}

class SettingSnapshot {
  const SettingSnapshot({
    required this.title,
    required this.description,
    required this.value,
  });

  final String title;
  final String description;
  final bool value;
}

class QuickActionSnapshot {
  const QuickActionSnapshot({
    required this.label,
    required this.side,
    this.player,
  });

  final String label;
  final String side;
  final String? player;
}

class PlayerSnapshot {
  const PlayerSnapshot({
    required this.name,
    required this.number,
    required this.side,
  });

  final String name;
  final int number;
  final String side;
}

class AppDemoData {
  const AppDemoData._();

  static const ProjectSnapshot nextProject = ProjectSnapshot(
    name: 'Spieltag 24',
    location: 'Ballsporthalle Freiberg',
    matchup: 'HSG Freiberg vs. HC Elbflorenz II',
    dateLabel: '20. April 2026, 18:30 Uhr',
    status: 'Bereit',
    note: 'Das nächste Projekt wird nach Datum automatisch priorisiert.',
  );

  static const ProjectSnapshot activeProject = ProjectSnapshot(
    name: 'Heimspiel Halbfinale',
    location: 'Sportzentrum Mitte',
    matchup: 'HSG Freiberg vs. TSV Altenburg',
    dateLabel: 'Heute, 19:00 Uhr',
    status: 'Live',
    note: 'Haupt-PC aktiv, Queue läuft stabil im TV-on-Modus.',
  );

  static const List<MetricSnapshot> dashboardMetrics = [
    MetricSnapshot(
      label: 'VLC',
      value: 'Verbunden',
      detail: 'Wiedergabeinstanz antwortet in 42 ms',
      color: AppColors.success,
    ),
    MetricSnapshot(
      label: 'Sync',
      value: 'Offline bereit',
      detail: 'Letzter Abgleich vor 6 Minuten',
      color: AppColors.info,
    ),
    MetricSnapshot(
      label: 'Medien',
      value: '96 % lokal',
      detail: '2 Sponsorclips fehlen noch auf dem Nebengerät',
      color: AppColors.warning,
    ),
    MetricSnapshot(
      label: 'Gerät',
      value: 'Haupt-PC',
      detail: 'Priorität aktiv, Übersteuerung erlaubt',
      color: AppColors.primary,
    ),
  ];

  static const List<AlertSnapshot> alerts = [
    AlertSnapshot(
      title: 'Sponsorclip gesperrt',
      message: 'Der aktuelle TV-on-Block ist vor manueller Überblendung geschützt.',
      tone: StatusBadgeTone.warning,
    ),
    AlertSnapshot(
      title: 'Nebengerät wartet',
      message: 'Ein vorbereitetes Projekt kann erst nach Freigabe vom Haupt-PC übernommen werden.',
      tone: StatusBadgeTone.info,
    ),
  ];

  static const List<ModuleSnapshot> systemModules = [
    ModuleSnapshot(
      title: 'Szenen & Queue-Logik',
      description: 'Regelt Abläufe, Prioritäten und die spätere Rückkehr an exakte Clip-Positionen.',
      icon: Icons.account_tree_rounded,
      color: AppColors.primary,
      items: ['Loop- und Rückkehrlogik', 'Live-Bearbeitung', 'Schutzregeln'],
    ),
    ModuleSnapshot(
      title: 'Offline & Sync',
      description: 'Sichert Projekte lokal und bereitet die spätere Gerätesynchronisation vor.',
      icon: Icons.cloud_sync_rounded,
      color: AppColors.info,
      items: ['Haupt-PC gewinnt', 'Lokale Verfügbarkeit', 'Letzter Sync'],
    ),
    ModuleSnapshot(
      title: 'Playback & VLC',
      description: 'Kapselt Wiedergabe, Status und Fehlerpfade für die LED-Ausspielung.',
      icon: Icons.play_circle_outline_rounded,
      color: AppColors.success,
      items: ['Start / Pause / Stop', 'Statusprüfung', 'Spätere VLC-Anbindung'],
    ),
    ModuleSnapshot(
      title: 'Logging & Backend',
      description: 'Bereitet Protokollierung, Geräteprofile und das spätere Supabase-Backend vor.',
      icon: Icons.receipt_long_rounded,
      color: AppColors.warning,
      items: ['Live-Logs', 'Gerätepriorität', 'Backend-Diagnose'],
    ),
  ];

  static const List<ProjectSnapshot> projects = [
    activeProject,
    nextProject,
    ProjectSnapshot(
      name: 'Auswärtsspiel Nord',
      location: 'Arena Dresden',
      matchup: 'HC Nord vs. HSG Freiberg',
      dateLabel: '27. April 2026, 17:00 Uhr',
      status: 'Entwurf',
      note: 'Mediathek und Szenenplanung sind noch offen.',
    ),
  ];

  static const Map<String, List<String>> projectAreas = {
    'Übersicht': ['Status, Datum, Standort', 'Projekt öffnen', 'Archiv und Filter'],
    'Stammdaten': ['Heim- und Gegnerteam', 'Notizen', 'Projektstatus'],
    'Medien': ['Clips zuordnen', 'Reihenfolge prüfen', 'Verfügbarkeit sehen'],
    'Szenen': ['Vor Spiel, Pause, Live', 'Quick-Actions vorbereiten', 'Fallback definieren'],
    'Teams & Spieler': ['Spielerlisten', 'Einlauf und Torlogik', 'Verletzungsaktionen'],
    'Projekt-Check': ['VLC-Check', 'Offline-Stand', 'Warnungen vor Live'],
  };

  static const List<String> mediaCategories = [
    'Sponsoren',
    'Einlauf',
    'TV off',
    'TV on',
    'Timeout',
    '2 Minuten',
    'Spieler',
    'Verletzung',
    'Wischer',
    'Spielende',
  ];

  static const List<MediaClipSnapshot> mediaClips = [
    MediaClipSnapshot(
      name: 'Sponsorblock A',
      category: 'Sponsoren',
      format: 'MP4',
      length: '00:18',
      status: 'Lokal verfügbar',
    ),
    MediaClipSnapshot(
      name: 'Einlauf Heim Pyro',
      category: 'Einlauf',
      format: 'MP4',
      length: '00:27',
      status: 'Bereit',
    ),
    MediaClipSnapshot(
      name: 'Timeout Neutral',
      category: 'Timeout',
      format: 'MP4',
      length: '00:14',
      status: 'Sync ausstehend',
    ),
    MediaClipSnapshot(
      name: 'Tor Jonas M.',
      category: 'Spieler',
      format: 'JPG',
      length: 'Standbild',
      status: 'Lokal verfügbar',
    ),
  ];

  static const Map<String, List<String>> liveActionColumns = {
    'Heim-Aktionen': [
      'Vor dem Spiel',
      'Einlauf Heim',
      '2 Minuten Heim',
      'Timeout Heim',
      'Tor Heim',
      'Verletzung Heim',
    ],
    'Gegner-Aktionen': [
      'Spielbeginn',
      'Einlauf Gegner',
      '2 Minuten Gegner',
      'Timeout Gegner',
      'Tor Gegner',
      'Verletzung Gegner',
    ],
  };

  static const QueueSnapshot liveQueue = QueueSnapshot(
    title: 'TV on / Sponsor-Loop',
    current: 'Clip 04 von 12: Premium Partner Intro',
    next: 'Clip 05: Hallenbranding Wechsel',
    protection: 'Schutzclip aktiv, nur kritische Aktionen dürfen unterbrechen.',
  );

  static const List<SettingSnapshot> settings = [
    SettingSnapshot(
      title: 'Haupt-PC-Modus',
      description: 'Dieses Gerät bleibt führend und gewinnt Konflikte.',
      value: true,
    ),
    SettingSnapshot(
      title: 'Sponsorclips schützen',
      description: 'Geschützte TV-on-Blöcke dürfen nicht normal übersteuert werden.',
      value: true,
    ),
    SettingSnapshot(
      title: 'Offline-Cache erzwingen',
      description: 'Projektmedien werden vor Live lokal geprüft.',
      value: true,
    ),
    SettingSnapshot(
      title: 'Warnungen prominent zeigen',
      description: 'Kritische Hinweise bleiben in Dashboard und Live sichtbar.',
      value: true,
    ),
  ];

  static const List<QuickActionSnapshot> quickActions = [
    QuickActionSnapshot(label: 'Tor Heim', side: 'Heim', player: 'Jonas M.'),
    QuickActionSnapshot(label: 'Tor Gegner', side: 'Gegner', player: 'Alex M.'),
    QuickActionSnapshot(label: 'Timeout Heim', side: 'Heim'),
    QuickActionSnapshot(label: '2 Minuten Gegner', side: 'Gegner'),
  ];

  static const List<PlayerSnapshot> players = [
    PlayerSnapshot(name: 'Jonas Meier', number: 7, side: 'Heim'),
    PlayerSnapshot(name: 'Paul Richter', number: 11, side: 'Heim'),
    PlayerSnapshot(name: 'Luca Neumann', number: 17, side: 'Heim'),
    PlayerSnapshot(name: 'Alex Müller', number: 9, side: 'Gegner'),
    PlayerSnapshot(name: 'Dennis Krause', number: 14, side: 'Gegner'),
    PlayerSnapshot(name: 'Mario Schenk', number: 3, side: 'Gegner'),
  ];

  static const List<AppSection> primarySections = AppSection.values;
}