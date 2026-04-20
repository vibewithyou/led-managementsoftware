import 'package:led_managementsoftware_app/data/datasources/local/local_queue_state_source.dart';
import 'package:led_managementsoftware_app/data/models/queue_state_dto.dart';

class InMemoryQueueStateSource implements LocalQueueStateSource {
  final Map<String, QueueStateDto> _store = {};

  @override
  Future<QueueStateDto?> readQueueState(String projectId) async {
    return _store[projectId];
  }

  @override
  Future<void> writeQueueState(QueueStateDto queueState) async {
    _store[queueState.projectId] = queueState;
  }

  @override
  Future<void> deleteQueueState(String projectId) async {
    _store.remove(projectId);
  }
}
