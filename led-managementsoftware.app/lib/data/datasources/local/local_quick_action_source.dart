import 'package:led_managementsoftware_app/data/models/quick_action_dto.dart';

abstract class LocalQuickActionSource {
  Future<List<QuickActionDto>> readQuickActions(String projectId);
  Future<void> writeQuickActions(List<QuickActionDto> actions);
  Future<void> deleteQuickAction(String id);
}
