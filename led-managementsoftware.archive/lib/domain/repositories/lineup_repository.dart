import 'package:led_management_software/domain/entities/lineup_entry.dart';
import 'package:led_management_software/domain/enums/team_type.dart';

abstract class LineupRepository {
  Future<List<LineupEntry>> getLineupForProject(String projectId);

  Future<List<LineupEntry>> getLineupForTeam({
    required String projectId,
    required TeamType teamType,
  });

  Future<void> saveLineupEntry(LineupEntry lineupEntry);

  Future<void> reorderLineup({
    required String projectId,
    required TeamType teamType,
    required List<String> entryIdsInOrder,
  });

  Future<void> deleteLineupEntry(String id);
}
