import 'package:led_managementsoftware_app/data/datasources/local/local_quick_action_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_quick_action_source.dart';
import 'package:led_managementsoftware_app/data/models/quick_action_dto.dart';
import 'package:led_managementsoftware_app/domain/entities/quick_action.dart';
import 'package:led_managementsoftware_app/domain/repositories/quick_action_repository.dart';

class QuickActionRepositoryImpl implements QuickActionRepository {
  QuickActionRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
  });

  final LocalQuickActionSource localSource;
  final RemoteQuickActionSource remoteSource;

  @override
  Future<List<QuickAction>> fetchQuickActions(String projectId) async {
    try {
      final remote = await remoteSource.fetchQuickActions(projectId);
      await localSource.writeQuickActions(remote);
      return remote.map((dto) => dto.toEntity()).toList(growable: false);
    } catch (_) {
      final local = await localSource.readQuickActions(projectId);
      return local.map((dto) => dto.toEntity()).toList(growable: false);
    }
  }

  @override
  Future<QuickAction> saveQuickAction(QuickAction action) async {
    final dto = QuickActionDto.fromEntity(action);

    try {
      final saved = await remoteSource.upsertQuickAction(dto);
      final currentLocal = await localSource.readQuickActions(action.id);
      final next = [...currentLocal.where((entry) => entry.id != saved.id), saved];
      await localSource.writeQuickActions(next);
      return saved.toEntity();
    } catch (_) {
      final currentLocal = await localSource.readQuickActions(action.id);
      final next = [...currentLocal.where((entry) => entry.id != dto.id), dto];
      await localSource.writeQuickActions(next);
      return dto.toEntity();
    }
  }

  @override
  Future<void> deleteQuickAction(String id) async {
    try {
      await remoteSource.deleteQuickAction(id);
    } catch (_) {
      // Ignore remote errors
    }
    await localSource.deleteQuickAction(id);
  }
}
