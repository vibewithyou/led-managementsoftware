import 'package:led_managementsoftware_app/data/models/queue_state_dto.dart';

abstract class LocalQueueStateSource {
  Future<QueueStateDto?> readQueueState(String projectId);
  Future<void> writeQueueState(QueueStateDto queueState);
  Future<void> deleteQueueState(String projectId);
}
