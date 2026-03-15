import 'package:flutter/foundation.dart';
import 'package:led_management_software/features/settings/model/hotkey_binding_model.dart';
import 'package:led_management_software/features/settings/model/setting_item_model.dart';
import 'package:led_management_software/features/settings/service/settings_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({SettingsService? service}) : _service = service ?? SettingsService.instance {
    _service.addListener(_forwardChanges);
  }

  final SettingsService _service;

  List<SettingItemModel> get playbackSettings => _service.loadPlaybackSettings();

  List<HotkeyBindingModel> get hotkeyBindings => _service.loadHotkeyBindings();

  List<String> get availableHotkeys => SettingsService.availableHotkeys;

  void updateHotkey(String eventLabel, String shortcutLabel) {
    _service.updateHotkey(eventLabel, shortcutLabel);
  }

  void _forwardChanges() {
    notifyListeners();
  }

  @override
  void dispose() {
    _service.removeListener(_forwardChanges);
    super.dispose();
  }
}
