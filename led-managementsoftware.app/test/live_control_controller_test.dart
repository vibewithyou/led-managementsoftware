import 'package:flutter_test/flutter_test.dart';
import 'package:led_managementsoftware_app/features/live_control/application/live_control_controller.dart';

void main() {
  test('protected clip blocks disallowed quick action', () async {
    final controller = LiveControlController();
    addTearDown(controller.dispose);

    await controller.changeScene('scene-live');
    final beforeScene = controller.queueState.activeSceneId;

    await controller.triggerQuickAction('Tor Heim');

    expect(controller.queueState.activeSceneId, beforeScene);
    expect(controller.logs.last.action, 'Unterbrechung blockiert');
  });

  test('queue-end interruption is executed after current clip chain', () async {
    final controller = LiveControlController();
    addTearDown(controller.dispose);

    await controller.changeScene('scene-live');
    await controller.triggerQuickAction('Timeout Heim');

    expect(controller.queueState.activeSceneId, 'scene-live');

    await controller.skipClip();
    await controller.skipClip();

    expect(controller.queueState.activeSceneId, 'scene-timeout-home');
  });
}
