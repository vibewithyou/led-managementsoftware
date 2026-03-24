import 'package:flutter/foundation.dart';
import 'package:led_management_software/features/live_control/model/live_action_config.dart';
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

  List<LiveActionConfig> get liveActions => _service.loadLiveActions();
  String get vlcExecutablePath => _service.vlcExecutablePath;
  String? get lastVlcError => _service.lastVlcError;

  List<String> get availableHotkeys => SettingsService.availableHotkeys;

  void updateHotkey(String eventLabel, String shortcutLabel) {
    _service.updateHotkey(eventLabel, shortcutLabel);
  }

  void updateActionEnabled(String actionId, bool enabled) {
    _service.updateLiveActionEnabled(actionId, enabled);
  }

  void updateActionColor(String actionId, LiveActionColorSemantic color) {
    _service.updateLiveActionColor(actionId, color);
  }

  void reorderActions(int oldIndex, int newIndex) {
    final actions = [...liveActions];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final moved = actions.removeAt(oldIndex);
    actions.insert(newIndex, moved);
    _service.reorderLiveActions(actions.map((item) => item.id).toList(growable: false));
  }

  void updateVlcExecutablePath(String value) {
    _service.updateVlcExecutablePath(value);
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
