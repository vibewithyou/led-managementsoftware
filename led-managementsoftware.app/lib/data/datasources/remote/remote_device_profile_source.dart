import 'package:led_managementsoftware_app/domain/entities/device_profile.dart';

abstract class RemoteDeviceProfileSource {
  Future<List<DeviceProfile>> fetchDeviceProfiles();
  Future<DeviceProfile> upsertDeviceProfile(DeviceProfile profile);
}
