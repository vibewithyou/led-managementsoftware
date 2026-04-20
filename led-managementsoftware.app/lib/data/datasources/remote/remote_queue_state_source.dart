import 'package:led_managementsoftware_app/data/models/queue_state_dto.dart';

abstract class RemoteQueueStateSource {
  Future<QueueStateDto?> fetchQueueState(String projectId);
  Future<QueueStateDto> upsertQueueState(QueueStateDto queueState);
  Future<void> deleteQueueState(String projectId);
}
