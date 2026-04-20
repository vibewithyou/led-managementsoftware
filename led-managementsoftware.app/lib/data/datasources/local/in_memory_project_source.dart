import 'package:led_managementsoftware_app/data/datasources/local/local_project_source.dart';
import 'package:led_managementsoftware_app/data/models/project_dto.dart';

class InMemoryProjectSource implements LocalProjectSource {
  final Map<String, ProjectDto> _store = {};

  @override
  Future<List<ProjectDto>> readProjects() async => _store.values.toList(growable: false);

  @override
  Future<void> writeProjects(List<ProjectDto> projects) async {
    _store
      ..clear()
      ..addEntries(projects.map((dto) => MapEntry(dto.id, dto)));
  }
}
