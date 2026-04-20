import 'package:led_managementsoftware_app/data/datasources/local/local_queue_state_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_queue_state_source.dart';
import 'package:led_managementsoftware_app/data/models/queue_state_dto.dart';
import 'package:led_managementsoftware_app/domain/entities/queue_state.dart';
import 'package:led_managementsoftware_app/domain/repositories/queue_state_repository.dart';

class QueueStateRepositoryImpl implements QueueStateRepository {
  QueueStateRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
  });

  final LocalQueueStateSource localSource;
  final RemoteQueueStateSource remoteSource;

  @override
  Future<QueueState?> fetchQueueState(String projectId) async {
    try {
      final remote = await remoteSource.fetchQueueState(projectId);
      if (remote != null) {
        await localSource.writeQueueState(remote);
        return remote.toEntity();
      }
    } catch (_) {
      // Fall back to local
    }
    final local = await localSource.readQueueState(projectId);
    return local?.toEntity();
  }

  @override
  Future<QueueState> saveQueueState(QueueState queueState) async {
    final dto = QueueStateDto.fromEntity(queueState);

    try {
      final saved = await remoteSource.upsertQueueState(dto);
      await localSource.writeQueueState(saved);
      return saved.toEntity();
    } catch (_) {
      await localSource.writeQueueState(dto);
      return dto.toEntity();
    }
  }

  @override
  Future<void> deleteQueueState(String projectId) async {
    try {
      await remoteSource.deleteQueueState(projectId);
    } catch (_) {
      // Ignore remote errors
    }
    await localSource.deleteQueueState(projectId);
  }
}
