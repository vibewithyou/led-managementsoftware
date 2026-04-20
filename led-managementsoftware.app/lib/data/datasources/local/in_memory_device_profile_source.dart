import 'package:led_managementsoftware_app/data/datasources/local/local_device_profile_source.dart';
import 'package:led_managementsoftware_app/domain/entities/device_profile.dart';

class InMemoryDeviceProfileSource implements LocalDeviceProfileSource {
  final Map<String, DeviceProfile> _store = {};

  @override
  Future<List<DeviceProfile>> readDeviceProfiles() async => _store.values.toList(growable: false);

  @override
  Future<void> writeDeviceProfiles(List<DeviceProfile> profiles) async {
    _store
      ..clear()
      ..addEntries(profiles.map((entry) => MapEntry(entry.id, entry)));
  }
}
