import 'package:led_management_software/features/settings/model/setting_item_model.dart';
import 'package:led_management_software/features/settings/service/settings_service.dart';

class SettingsController {
  SettingsController({SettingsService? service}) : _service = service ?? const SettingsService();

  final SettingsService _service;

  List<SettingItemModel> get playbackSettings => _service.loadPlaybackSettings();
}
