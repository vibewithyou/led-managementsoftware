import 'package:flutter/material.dart';
import 'package:led_management_software/features/settings/model/setting_item_model.dart';

class SettingSwitchTile extends StatelessWidget {
  const SettingSwitchTile({
    required this.item,
    required this.onChanged,
    super.key,
  });

  final SettingItemModel item;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: item.enabled,
      onChanged: onChanged,
      title: Text(item.title),
      subtitle: Text(item.description),
      contentPadding: EdgeInsets.zero,
    );
  }
}
