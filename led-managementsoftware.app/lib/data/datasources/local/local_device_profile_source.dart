import 'package:led_managementsoftware_app/domain/entities/device_profile.dart';

abstract class LocalDeviceProfileSource {
  Future<List<DeviceProfile>> readDeviceProfiles();
  Future<void> writeDeviceProfiles(List<DeviceProfile> profiles);
}
