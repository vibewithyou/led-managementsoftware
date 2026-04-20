import 'package:led_managementsoftware_app/data/datasources/local/local_quick_action_source.dart';
import 'package:led_managementsoftware_app/data/models/quick_action_dto.dart';

class InMemoryQuickActionSource implements LocalQuickActionSource {
  final Map<String, QuickActionDto> _store = {};

  @override
  Future<List<QuickActionDto>> readQuickActions(String projectId) async {
    return _store.values
        .where((action) => action.id.startsWith('$projectId-'))
        .toList(growable: false);
  }

  @override
  Future<void> writeQuickActions(List<QuickActionDto> actions) async {
    for (final action in actions) {
      _store[action.id] = action;
    }
  }

  @override
  Future<void> deleteQuickAction(String id) async {
    _store.remove(id);
  }
}
