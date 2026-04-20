import 'package:led_managementsoftware_app/data/models/quick_action_dto.dart';

abstract class RemoteQuickActionSource {
  Future<List<QuickActionDto>> fetchQuickActions(String projectId);
  Future<QuickActionDto> upsertQuickAction(QuickActionDto action);
  Future<void> deleteQuickAction(String id);
}
