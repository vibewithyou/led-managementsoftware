import 'package:flutter_test/flutter_test.dart';
import 'package:led_managementsoftware_app/core/app/led_control_app.dart';
import 'package:led_managementsoftware_app/core/config/backend_config.dart';
import 'package:led_managementsoftware_app/core/config/backend_runtime.dart';

void main() {
  testWidgets('shows dashboard shell on startup', (tester) async {
    const runtime = BackendRuntime(
      config: BackendConfig(
        environment: 'test',
        enableRemoteSync: false,
        mainDeviceId: 'main-pc',
        mainPcPriority: true,
      ),
      statusMessage: 'Offline-Modus aktiv',
    );

    await tester.pumpWidget(const LedControlApp(backendRuntime: runtime));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Regieoberfläche für die komplette Spielsteuerung'), findsOneWidget);
    expect(find.text('Aktives Projekt'), findsOneWidget);
    expect(find.text('Systemmodule'), findsOneWidget);
  });
}
