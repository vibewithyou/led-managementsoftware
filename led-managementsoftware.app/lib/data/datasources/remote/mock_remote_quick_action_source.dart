import 'package:led_managementsoftware_app/data/datasources/remote/remote_quick_action_source.dart';
import 'package:led_managementsoftware_app/data/models/quick_action_dto.dart';

class MockRemoteQuickActionSource implements RemoteQuickActionSource {
  final Map<String, QuickActionDto> _store = {};

  @override
  Future<List<QuickActionDto>> fetchQuickActions(String projectId) async {
    return _store.values
        .where((action) => action.id.startsWith('$projectId-'))
        .toList(growable: false);
  }

  @override
  Future<QuickActionDto> upsertQuickAction(QuickActionDto action) async {
    _store[action.id] = action;
    return action;
  }

  @override
  Future<void> deleteQuickAction(String id) async {
    _store.remove(id);
  }
}
