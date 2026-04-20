import 'package:flutter/material.dart';

enum AppRoute {
  dashboard('/dashboard', 'Dashboard', Icons.dashboard_rounded),
  mediaLibrary('/media-library', 'Medienbibliothek', Icons.video_library_rounded),
  liveControl('/live-control', 'Live-Steuerung', Icons.sensors_rounded),
  introPlayers('/intro-players', 'Intro / Spieler', Icons.groups_rounded),
  projects('/projects', 'Projekte', Icons.folder_copy_rounded),
  settings('/settings', 'Einstellungen', Icons.settings_rounded);

  const AppRoute(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;

  static AppRoute fromName(String? name) {
    return AppRoute.values.firstWhere(
      (route) => route.path == name,
      orElse: () => AppRoute.dashboard,
    );
  }
}
