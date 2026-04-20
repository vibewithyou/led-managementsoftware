import 'package:led_managementsoftware_app/domain/entities/quick_action.dart';

abstract class QuickActionRepository {
  Future<List<QuickAction>> fetchQuickActions(String projectId);
  Future<QuickAction> saveQuickAction(QuickAction action);
  Future<void> deleteQuickAction(String id);
}
