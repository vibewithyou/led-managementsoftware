import 'package:led_managementsoftware_app/data/datasources/remote/remote_queue_state_source.dart';
import 'package:led_managementsoftware_app/data/models/queue_state_dto.dart';

class MockRemoteQueueStateSource implements RemoteQueueStateSource {
  final Map<String, QueueStateDto> _store = {};

  @override
  Future<QueueStateDto?> fetchQueueState(String projectId) async {
    return _store[projectId];
  }

  @override
  Future<QueueStateDto> upsertQueueState(QueueStateDto queueState) async {
    _store[queueState.projectId] = queueState;
    return queueState;
  }

  @override
  Future<void> deleteQueueState(String projectId) async {
    _store.remove(projectId);
  }
}
