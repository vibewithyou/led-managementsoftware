import 'package:flutter/material.dart';
import 'package:led_managementsoftware_app/shared/widgets/surfaces/app_panel.dart';

class ScenesScreen extends StatelessWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPanel(
      title: 'Szenen',
      subtitle: 'Szenenverwaltung mit Reihenfolge, Unterbrechung und Rückkehrverhalten.',
      child: Text('Szenenmodul ist strukturell vorbereitet und wird in Teil 3 funktional vertieft.'),
    );
  }
}
