class HotkeyBindingModel {
  const HotkeyBindingModel({
    required this.eventLabel,
    required this.description,
    required this.shortcutLabel,
  });

  final String eventLabel;
  final String description;
  final String shortcutLabel;

  HotkeyBindingModel copyWith({
    String? eventLabel,
    String? description,
    String? shortcutLabel,
  }) {
    return HotkeyBindingModel(
      eventLabel: eventLabel ?? this.eventLabel,
      description: description ?? this.description,
      shortcutLabel: shortcutLabel ?? this.shortcutLabel,
    );
  }
}