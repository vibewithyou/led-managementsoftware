import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/config/app_demo_data.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/app_panel.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class MediaLibraryScreen extends StatelessWidget {
  const MediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1260;

        if (compact) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _libraryHeader(),
                const SizedBox(height: 18),
                _categoriesPanel(),
                const SizedBox(height: 18),
                _clipGrid(),
                const SizedBox(height: 18),
                _inspectorPanel(),
              ],
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _categoriesPanel()),
            const SizedBox(width: 18),
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _libraryHeader(),
                    const SizedBox(height: 18),
                    _clipGrid(),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(child: _inspectorPanel()),
          ],
        );
      },
    );
  }

  Widget _libraryHeader() {
    return AppPanel(
      title: 'Mediathek',
      subtitle: 'Zentrale Verwaltung für MP4 und JPG mit Kategorien, Suchlogik, Projektbezug und Offline-Stand.',
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Nach Clips, Kategorien oder Tags suchen',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusBadge(label: 'Projektzuordnung sichtbar', tone: StatusBadgeTone.info),
              StatusBadge(label: 'Lokale Verfügbarkeit', tone: StatusBadgeTone.success),
              StatusBadge(label: 'Sync-Status vorbereitet', tone: StatusBadgeTone.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoriesPanel() {
    return AppPanel(
      title: 'Kategorien',
      subtitle: 'Systemkategorien plus freie Erweiterung pro Club und Spieltag.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final category in AppDemoData.mediaCategories)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundRaised,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.label_rounded, color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(category)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _clipGrid() {
    return AppPanel(
      title: 'Clips & Assets',
      subtitle: 'Teil 1 legt die Struktur für Kartenansicht, Vorschau, Tags und projektbezogene Zuordnung an.',
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final clip in AppDemoData.mediaClips)
            SizedBox(
              width: 260,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundRaised,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 116,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E2F47), Color(0xFF101923)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.movie_creation_outlined, size: 34, color: AppColors.textSoft),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(clip.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('${clip.category} · ${clip.format} · ${clip.length}', style: const TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 10),
                    StatusBadge(
                      label: clip.status,
                      tone: clip.status == 'Sync ausstehend' ? StatusBadgeTone.warning : StatusBadgeTone.success,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _inspectorPanel() {
    return AppPanel(
      title: 'Metadaten & Vorschau',
      subtitle: 'Rechter Bereich für die spätere Detailpflege ohne die Hauptliste zu verlassen.',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InspectorRow(label: 'Name', value: 'Sponsorblock A'),
          _InspectorRow(label: 'Kategorie', value: 'Sponsoren'),
          _InspectorRow(label: 'Tags', value: 'Premium, Loop, Hallenpause'),
          _InspectorRow(label: 'Projektbezug', value: 'Heimspiel Halbfinale'),
          _InspectorRow(label: 'Lokal', value: 'Ja, auf Haupt-PC und Tablet-Cache'),
          _InspectorRow(label: 'Serverstatus', value: 'Metadaten synchron, Dateiabgleich folgt'),
        ],
      ),
    );
  }
}

class _InspectorRow extends StatelessWidget {
  const _InspectorRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.textSoft, height: 1.45)),
        ],
      ),
    );
  }
}