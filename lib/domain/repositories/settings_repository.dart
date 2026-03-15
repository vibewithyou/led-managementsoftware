abstract class SettingsRepository {
  Future<Map<String, dynamic>> loadGlobalSettings();

  Future<void> saveGlobalSettings(Map<String, dynamic> settings);

  Future<Map<String, dynamic>> loadProjectSettings(String projectId);

  Future<void> saveProjectSettings({
    required String projectId,
    required Map<String, dynamic> settings,
  });
}
