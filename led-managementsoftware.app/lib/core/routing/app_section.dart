import 'package:flutter/material.dart';

enum AppSection {
  dashboard('Dashboard', 'Übersicht, Warnungen und Projektlage', Icons.space_dashboard_rounded),
  projects('Projekte', 'Planung, Zuordnung und Projektstatus', Icons.folder_open_rounded),
  mediaLibrary('Mediathek', 'Clips, Kategorien und Verfügbarkeit', Icons.video_library_rounded),
  liveControl('Live-Steuerung', 'Schnelle Regie für laufende Abläufe', Icons.tune_rounded),
  settings('Einstellungen', 'Gerät, Playback, Regeln und Diagnose', Icons.settings_rounded);

  const AppSection(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;
}