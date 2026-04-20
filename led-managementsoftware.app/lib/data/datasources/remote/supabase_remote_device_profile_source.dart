import 'package:led_managementsoftware_app/data/datasources/remote/remote_device_profile_source.dart';
import 'package:led_managementsoftware_app/data/datasources/remote/supabase_tables.dart';
import 'package:led_managementsoftware_app/domain/entities/device_profile.dart';
import 'package:led_managementsoftware_app/domain/enums/device_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRemoteDeviceProfileSource implements RemoteDeviceProfileSource {
  SupabaseRemoteDeviceProfileSource(this.client);

  final SupabaseClient client;

  @override
  Future<List<DeviceProfile>> fetchDeviceProfiles() async {
    final response = await client.from(SupabaseTables.deviceProfiles).select().order('updated_at', ascending: false);
    return response.map((map) {
      return DeviceProfile(
        id: map['id'] as String,
        name: map['name'] as String,
        type: DeviceTypeX.fromValue(map['type'] as String),
        isOnline: map['is_online'] as bool,
        lastSyncAt: DateTime.parse(map['last_sync_at'] as String),
      );
    }).toList(growable: false);
  }

  @override
  Future<DeviceProfile> upsertDeviceProfile(DeviceProfile profile) async {
    final response = await client
        .from(SupabaseTables.deviceProfiles)
        .upsert({
          'id': profile.id,
          'name': profile.name,
          'type': profile.type.name,
          'is_online': profile.isOnline,
          'last_sync_at': profile.lastSyncAt.toIso8601String(),
        }, onConflict: 'id')
        .select()
        .single();

    return DeviceProfile(
      id: response['id'] as String,
      name: response['name'] as String,
      type: DeviceTypeX.fromValue(response['type'] as String),
      isOnline: response['is_online'] as bool,
      lastSyncAt: DateTime.parse(response['last_sync_at'] as String),
    );
  }
}
