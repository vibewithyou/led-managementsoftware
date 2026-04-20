import 'package:led_managementsoftware_app/domain/entities/queue_state.dart';

abstract class QueueStateRepository {
  Future<QueueState?> fetchQueueState(String projectId);
  Future<QueueState> saveQueueState(QueueState queueState);
  Future<void> deleteQueueState(String projectId);
}
