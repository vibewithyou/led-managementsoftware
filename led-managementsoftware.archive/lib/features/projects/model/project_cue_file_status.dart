enum ProjectCueFileStatus {
  available('Datei ok'),
  missing('Datei fehlt'),
  metadataIncomplete('Metadaten unvollstaendig');

  const ProjectCueFileStatus(this.label);

  final String label;
}