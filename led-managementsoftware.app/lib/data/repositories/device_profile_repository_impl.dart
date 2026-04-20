import 'package:led_managementsoftware_app/data/datasources/local/local_device_profile_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/remote_device_profile_source.dart';
import 'package:led_managementsoftware_app/domain/entities/device_profile.dart';
import 'package:led_managementsoftware_app/domain/repositories/device_profile_repository.dart';

class DeviceProfileRepositoryImpl implements DeviceProfileRepository {
  DeviceProfileRepositoryImpl({
    required this.localSource,
    required this.remoteSource,
  });

  final LocalDeviceProfileSource localSource;
  final RemoteDeviceProfileSource remoteSource;

  @override
  Future<List<DeviceProfile>> fetchDeviceProfiles() async {
    try {
      final remote = await remoteSource.fetchDeviceProfiles();
      await localSource.writeDeviceProfiles(remote);
      return remote;
    } catch (_) {
      return localSource.readDeviceProfiles();
    }
  }

  @override
  Future<DeviceProfile> saveDeviceProfile(DeviceProfile profile) async {
    try {
      final saved = await remoteSource.upsertDeviceProfile(profile);
      final all = await localSource.readDeviceProfiles();
      final next = [...all.where((entry) => entry.id != saved.id), saved];
      await localSource.writeDeviceProfiles(next);
      return saved;
    } catch (_) {
      final all = await localSource.readDeviceProfiles();
      final next = [...all.where((entry) => entry.id != profile.id), profile];
      await localSource.writeDeviceProfiles(next);
      return profile;
    }
  }
}
