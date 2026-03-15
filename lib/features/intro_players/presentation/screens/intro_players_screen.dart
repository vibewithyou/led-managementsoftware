import 'package:flutter/material.dart';
import 'package:led_management_software/core/constants/app_spacing.dart';
import 'package:led_management_software/features/intro_players/controller/intro_players_controller.dart';
import 'package:led_management_software/features/intro_players/widgets/player_intro_card.dart';
import 'package:led_management_software/shared/widgets/layout/page_header.dart';
import 'package:led_management_software/shared/widgets/surfaces/app_panel.dart';

class IntroPlayersScreen extends StatelessWidget {
  const IntroPlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = IntroPlayersController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Intro / Spieler',
          description: 'Vorbereitung und Triggern der Spieler-Intros für Einlauf und Teamvorstellung.',
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: AppPanel(
                  title: 'Lineup',
                  child: ListView.separated(
                    itemCount: controller.lineup.length,
                    itemBuilder: (_, index) => PlayerIntroCard(player: controller.lineup[index]),
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: AppPanel(
                  title: 'Trigger-Reihenfolge',
                  child: Column(
                    children: [
                      ListTile(contentPadding: EdgeInsets.zero, title: Text('1. Team Intro Opener'), trailing: Text('Ready')),
                      ListTile(contentPadding: EdgeInsets.zero, title: Text('2. Torhüter + Backcourt'), trailing: Text('Ready')),
                      ListTile(contentPadding: EdgeInsets.zero, title: Text('3. Wings + Kreisläufer'), trailing: Text('Pending')),
                      ListTile(contentPadding: EdgeInsets.zero, title: Text('4. Startformation Finale'), trailing: Text('Pending')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
