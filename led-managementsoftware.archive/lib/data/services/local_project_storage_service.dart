class LocalProjectStorageService {
  const LocalProjectStorageService();

  Future<void> initialize() async {}

  Future<List<String>> loadRecentProjects() async {
    return const [
      'Bundesliga Matchday 23',
      'European Cup Quarterfinal',
      'Preseason Arena Test',
    ];
  }
}
