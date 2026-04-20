import 'package:led_managementsoftware_app/domain/entities/device_profile.dart';

abstract class DeviceProfileRepository {
  Future<List<DeviceProfile>> fetchDeviceProfiles();
  Future<DeviceProfile> saveDeviceProfile(DeviceProfile profile);
}
