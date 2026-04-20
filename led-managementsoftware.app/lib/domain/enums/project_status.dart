enum ProjectStatus { draft, ready, live, finished, archived }

extension ProjectStatusX on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.draft:
        return 'Entwurf';
      case ProjectStatus.ready:
        return 'Bereit';
      case ProjectStatus.live:
        return 'Live';
      case ProjectStatus.finished:
        return 'Beendet';
      case ProjectStatus.archived:
        return 'Archiviert';
    }
  }

  String get value => name;

  static ProjectStatus fromValue(String raw) {
    return ProjectStatus.values.firstWhere(
      (status) => status.name == raw,
      orElse: () => ProjectStatus.draft,
    );
  }
}
