import 'package:led_managementsoftware_app/core/config/backend_runtime.dart';
import 'package:led_managementsoftware_app/data/datasources/local/in_memory_device_profile_source.dart';
import 'package:led_managementsoftware_app/data/datasources/local/in_memory_live_log_source.dart';
import 'package:led_managementsoftware_app/data/datasources/local/in_memory_media_source.dart';
import 'package:led_managementsoftware_app/data/datasources/local/in_memory_project_source.dart';
import 'package:led_managementsoftware_app/data/datasources/local/in_memory_scene_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/offline_remote_device_profile_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/offline_remote_live_log_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/offline_remote_media_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/offline_remote_project_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/offline_remote_scene_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_device_profile_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_live_log_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_media_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_project_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_scene_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/supabase_remote_device_profile_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/supabase_remote_live_log_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/supabase_remote_media_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/supabase_remote_project_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/supabase_remote_scene_source.dart';
import 'package:led_managementsoftware_app/data/repositories/device_profile_repository_impl.dart';
import 'package:led_managementsoftware_app/data/repositories/live_log_repository_impl.dart';
import 'package:led_managementsoftware_app/data/repositories/media_repository_impl.dart';
import 'package:led_managementsoftware_app/data/repositories/project_repository_impl.dart';
import 'package:led_managementsoftware_app/data/repositories/scene_repository_impl.dart';

class RepositoryFactory {
  RepositoryFactory(this.runtime);

  final BackendRuntime runtime;

  late final projectRepository = ProjectRepositoryImpl(
    localSource: InMemoryProjectSource(),
    remoteSource: _projectSource(),
  );

  late final mediaRepository = MediaRepositoryImpl(
    localSource: InMemoryMediaSource(),
    remoteSource: _mediaSource(),
  );

  late final sceneRepository = SceneRepositoryImpl(
    localSource: InMemorySceneSource(),
    remoteSource: _sceneSource(),
  );

  late final deviceRepository = DeviceProfileRepositoryImpl(
    localSource: InMemoryDeviceProfileSource(),
    remoteSource: _deviceSource(),
  );

  late final logRepository = LiveLogRepositoryImpl(
    localSource: InMemoryLiveLogSource(),
    remoteSource: _logSource(),
  );

  RemoteProjectSource _projectSource() {
    if (runtime.remoteEnabled) {
      return SupabaseRemoteProjectSource(runtime.client!);
    }
    return OfflineRemoteProjectSource();
  }

  RemoteMediaSource _mediaSource() {
    if (runtime.remoteEnabled) {
      return SupabaseRemoteMediaSource(runtime.client!);
    }
    return OfflineRemoteMediaSource();
  }

  RemoteSceneSource _sceneSource() {
    if (runtime.remoteEnabled) {
      return SupabaseRemoteSceneSource(runtime.client!);
    }
    return OfflineRemoteSceneSource();
  }

  RemoteDeviceProfileSource _deviceSource() {
    if (runtime.remoteEnabled) {
      return SupabaseRemoteDeviceProfileSource(runtime.client!);
    }
    return OfflineRemoteDeviceProfileSource();
  }

  RemoteLiveLogSource _logSource() {
    if (runtime.remoteEnabled) {
      return SupabaseRemoteLiveLogSource(runtime.client!);
    }
    return OfflineRemoteLiveLogSource();
  }
}
