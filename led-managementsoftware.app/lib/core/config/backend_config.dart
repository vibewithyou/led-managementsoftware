class BackendConfig {
  const BackendConfig({
    required this.environment,
    required this.enableRemoteSync,
    required this.mainDeviceId,
    required this.mainPcPriority,
    this.supabaseUrl,
    this.supabaseAnonOrPublishableKey,
  });

  final String environment;
  final bool enableRemoteSync;
  final String mainDeviceId;
  final bool mainPcPriority;
  final String? supabaseUrl;
  final String? supabaseAnonOrPublishableKey;

  bool get hasSupabaseCredentials {
    return (supabaseUrl?.isNotEmpty ?? false) &&
        (supabaseAnonOrPublishableKey?.isNotEmpty ?? false);
  }

  factory BackendConfig.fromEnvironment({
    required String environment,
    required bool enableRemoteSync,
    required String? supabaseUrl,
    required String? supabaseAnonOrPublishableKey,
    required String mainDeviceId,
    required bool mainPcPriority,
  }) {
    return BackendConfig(
      environment: environment,
      enableRemoteSync: enableRemoteSync,
      supabaseUrl: supabaseUrl,
      supabaseAnonOrPublishableKey: supabaseAnonOrPublishableKey,
      mainDeviceId: mainDeviceId,
      mainPcPriority: mainPcPriority,
    );
  }
}
