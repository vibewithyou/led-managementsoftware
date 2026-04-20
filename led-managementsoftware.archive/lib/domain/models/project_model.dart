class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final DateTime lastUpdated;
}
