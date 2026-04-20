import 'package:led_managementsoftware_app/data/models/project_dto.dart';
import 'package:led_managementsoftware_app/domain/entities/project.dart';

class ProjectMapper {
  const ProjectMapper._();

  static Project fromDto(ProjectDto dto) => dto.toEntity();
  static ProjectDto toDto(Project entity) => ProjectDto.fromEntity(entity);
}
