import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/core/config/app_demo_data.dart';
import 'package:led_managementsoftware_app/core/theme/app_colors.dart';
import 'package:led_managementsoftware_app/shared/widgets/forms/labeled_text_field.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/app_panel.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/status_badge.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> with TickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1180;

        return Column(
          children: [
            _tabBarHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _overviewTab(compact),
                  _masterDataTab(),
                  _mediaTab(),
                  _scenesTab(),
                  _teamsTab(),
                  _projectCheckTab(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _tabBarHeader() {
    return AppPanel(
      title: 'Projektsteuerung',
      subtitle: 'Teil 2 führt die Projektansicht als Arbeitsbereich mit klaren Unterseiten und Subwidgets.',
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StatusBadge(label: 'Projektarchitektur aktiv', tone: StatusBadgeTone.success),
                StatusBadge(label: 'Datenmodell vorbereitet', tone: StatusBadgeTone.info),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              dividerColor: Colors.transparent,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(text: 'Übersicht'),
                Tab(text: 'Stammdaten'),
                Tab(text: 'Medien'),
                Tab(text: 'Szenen'),
                Tab(text: 'Teams & Spieler'),
                Tab(text: 'Projekt-Check'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewTab(bool compact) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppPanel(
            title: 'Projektübersicht',
            subtitle: 'Status, Datum, Standort und Live-Bereitschaft bleiben zentral sichtbar.',
            child: Column(
              children: [
                for (final project in AppDemoData.projects)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundRaised,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(project.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
                            StatusBadge(
                              label: project.status,
                              tone: project.status == 'Live'
                                  ? StatusBadgeTone.success
                                  : project.status == 'Bereit'
                                      ? StatusBadgeTone.info
                                      : StatusBadgeTone.neutral,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(project.matchup, style: const TextStyle(color: AppColors.textSoft)),
                        const SizedBox(height: 6),
                        Text('${project.location} · ${project.dateLabel}', style: const TextStyle(color: AppColors.textMuted)),
                        const SizedBox(height: 10),
                        Text(project.note, style: const TextStyle(color: AppColors.textMuted, height: 1.45)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (compact)
            _readinessPanel()
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _readinessPanel()),
                const SizedBox(width: 18),
                Expanded(child: _projectAreaPanel()),
              ],
            ),
          if (compact) ...[
            const SizedBox(height: 18),
            _projectAreaPanel(),
          ],
        ],
      ),
    );
  }

  Widget _masterDataTab() {
    return SingleChildScrollView(
      child: AppPanel(
        title: 'Stammdaten',
        subtitle: 'Heim- und Gegnerdaten getrennt, gut prüfbar und schnell anpassbar.',
        child: const Column(
          children: [
            LabeledTextField(label: 'Projektname', hint: 'Heimspiel Halbfinale'),
            SizedBox(height: 12),
            LabeledTextField(label: 'Spielpaarung', hint: 'HSG Freiberg vs. TSV Altenburg'),
            SizedBox(height: 12),
            LabeledTextField(label: 'Standort', hint: 'Sportzentrum Mitte'),
            SizedBox(height: 12),
            LabeledTextField(label: 'Notiz', hint: 'Sponsorblock vor Spielbeginn priorisieren'),
          ],
        ),
      ),
    );
  }

  Widget _mediaTab() {
    return const Center(
      child: Text('Medienzuordnung erfolgt zentral in der Mediathek und bleibt hier als Projektkontext verlinkt.'),
    );
  }

  Widget _scenesTab() {
    return AppPanel(
      title: 'Szenenstatus',
      subtitle: 'Szenen werden in Teil 3 funktional erweitert, sind hier aber bereits projektspezifisch sichtbar.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _PreparationRow(title: 'Vor dem Spiel', detail: 'Einlauf, Intro, erste Sponsorläufe'),
          _PreparationRow(title: 'TV on', detail: 'Laufende Sponsorrotation mit Unterbrechungsregeln'),
          _PreparationRow(title: 'Pause', detail: 'Pause-Loop mit priorisierten Aktionen'),
          _PreparationRow(title: 'Nachspiel', detail: 'Abschlussclip und Fallback auf Hallenbranding'),
        ],
      ),
    );
  }

  Widget _teamsTab() {
    return AppPanel(
      title: 'Teams & Spieler',
      subtitle: 'Spielerlisten pro Seite als Grundlage für spätere Quick-Actions.',
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          for (final side in const ['Heim', 'Gegner'])
            SizedBox(
              width: 320,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundRaised,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(side, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    for (final player in AppDemoData.players.where((entry) => entry.side == side))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('#${player.number} ${player.name}', style: const TextStyle(color: AppColors.textSoft)),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _projectCheckTab() {
    return AppPanel(
      title: 'Projekt-Check',
      subtitle: 'Kurzprüfung vor Live-Start mit Fokus auf VLC, Offline, Sync und Warnungen.',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreparationRow(title: 'VLC', detail: 'Verbindung und Transportbefehle geprüft'),
          _PreparationRow(title: 'Offline', detail: 'Medien vollständig lokal verfügbar'),
          _PreparationRow(title: 'Sync', detail: 'Letzter Abgleich erfolgreich, kein Konflikt'),
          _PreparationRow(title: 'Warnungen', detail: 'Keine kritischen Blocker offen'),
        ],
      ),
    );
  }

  Widget _readinessPanel() {
    return AppPanel(
      title: 'Live-Vorbereitung',
      subtitle: 'Die wichtigsten Projektbereiche für den Übergang vom Entwurf in den Live-Betrieb.',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreparationRow(title: 'Mediathek', detail: 'Clips zuordnen, Reihenfolge prüfen, lokale Verfügbarkeit sichern'),
          _PreparationRow(title: 'Szenen', detail: 'Vor dem Spiel, TV on, Pause und Nachspiel sauber vorbereiten'),
          _PreparationRow(title: 'Teams & Spieler', detail: 'Heim und Gegner mit Schnellaktionen für Einlauf, Tor und Verletzung'),
          _PreparationRow(title: 'Projekt-Check', detail: 'VLC, Offline-Stand, Warnungen und Haupt-PC-Status vor Live prüfen'),
        ],
      ),
    );
  }

  Widget _projectAreaPanel() {
    return AppPanel(
      title: 'Projektbereiche',
      subtitle: 'Jeder Bereich wird als eigenständiges Subwidget geführt.',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final entry in AppDemoData.projectAreas.entries)
            SizedBox(
              width: 280,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundRaised,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    for (final item in entry.value)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text('• $item', style: const TextStyle(color: AppColors.textMuted)),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PreparationRow extends StatelessWidget {
  const _PreparationRow({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundRaised,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(detail, style: const TextStyle(color: AppColors.textMuted, height: 1.45)),
        ],
      ),
    );
  }
}
