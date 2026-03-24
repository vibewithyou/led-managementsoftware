import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

/// Registers system-wide desktop hotkeys and debounces repeated keydown bursts.
class GlobalHotkeyService {
  GlobalHotkeyService._();

  static final GlobalHotkeyService instance = GlobalHotkeyService._();

  final Map<String, HotKey> _registeredHotkeys = {};
  final Map<String, DateTime> _lastTriggeredAt = {};

  bool _isRegistered = false;
  Duration _debounceDuration = const Duration(milliseconds: 350);

  bool get isRegistered => _isRegistered;

  Future<void> initialize() async {
    if (kIsWeb) {
      _registeredHotkeys.clear();
      _lastTriggeredAt.clear();
      _isRegistered = false;
      return;
    }
    await hotKeyManager.unregisterAll();
    _registeredHotkeys.clear();
    _lastTriggeredAt.clear();
    _isRegistered = false;
  }

  Future<void> registerHotkeys({
    required Map<String, String> bindings,
    required ValueChanged<String> onTriggered,
    Duration debounceDuration = const Duration(milliseconds: 350),
  }) async {
    if (kIsWeb) {
      _registeredHotkeys.clear();
      _lastTriggeredAt.clear();
      _isRegistered = false;
      return;
    }
    _debounceDuration = debounceDuration;
    await unregisterAll();

    for (final entry in bindings.entries) {
      final hotKey = _buildHotKey(entry.value);
      if (hotKey == null) {
        debugPrint('[GlobalHotkeyService] Unsupported hotkey: ${entry.value}');
        continue;
      }

      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (_) {
          if (_shouldDebounce(entry.key)) {
            return;
          }
          _lastTriggeredAt[entry.key] = DateTime.now();
          debugPrint('[GlobalHotkeyService] Triggered ${entry.key} via ${entry.value}');
          onTriggered(entry.key);
        },
      );

      _registeredHotkeys[entry.key] = hotKey;
    }

    _isRegistered = _registeredHotkeys.isNotEmpty;
  }

  Future<void> unregisterAll() async {
    if (kIsWeb) {
      _registeredHotkeys.clear();
      _isRegistered = false;
      return;
    }
    await hotKeyManager.unregisterAll();
    _registeredHotkeys.clear();
    _isRegistered = false;
  }

  bool _shouldDebounce(String action) {
    final lastTriggered = _lastTriggeredAt[action];
    if (lastTriggered == null) {
      return false;
    }

    return DateTime.now().difference(lastTriggered) < _debounceDuration;
  }

  HotKey? _buildHotKey(String shortcutLabel) {
    final normalized = shortcutLabel.trim().toUpperCase();
    final key = switch (normalized) {
      'F1' => PhysicalKeyboardKey.f1,
      'F2' => PhysicalKeyboardKey.f2,
      'F3' => PhysicalKeyboardKey.f3,
      'F4' => PhysicalKeyboardKey.f4,
      'F5' => PhysicalKeyboardKey.f5,
      'F6' => PhysicalKeyboardKey.f6,
      'F7' => PhysicalKeyboardKey.f7,
      'F8' => PhysicalKeyboardKey.f8,
      'F9' => PhysicalKeyboardKey.f9,
      'F10' => PhysicalKeyboardKey.f10,
      'F11' => PhysicalKeyboardKey.f11,
      'F12' => PhysicalKeyboardKey.f12,
      _ => null,
    };

    if (key == null) {
      return null;
    }

    return HotKey(
      key: key,
      scope: HotKeyScope.system,
    );
  }
}