import 'package:led_managementsoftware_app/data/datasources/remote/remote_device_profile_source.dart';
import 'package:led_managementsoftware_app/domain/entities/device_profile.dart';

class OfflineRemoteDeviceProfileSource implements RemoteDeviceProfileSource {
  final Map<String, DeviceProfile> _store = {};

  @override
  Future<List<DeviceProfile>> fetchDeviceProfiles() async => _store.values.toList(growable: false);

  @override
  Future<DeviceProfile> upsertDeviceProfile(DeviceProfile profile) async {
    _store[profile.id] = profile;
    return profile;
  }
}
