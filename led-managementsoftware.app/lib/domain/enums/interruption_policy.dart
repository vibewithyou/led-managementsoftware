enum InterruptionPolicy { immediate, queueEnd, sceneEnd }

extension InterruptionPolicyX on InterruptionPolicy {
  String get label {
    switch (this) {
      case InterruptionPolicy.immediate:
        return 'Sofort';
      case InterruptionPolicy.queueEnd:
        return 'Am Queue-Ende';
      case InterruptionPolicy.sceneEnd:
        return 'Am Szenenende';
    }
  }

  static InterruptionPolicy fromValue(String raw) {
    return InterruptionPolicy.values.firstWhere(
      (policy) => policy.name == raw,
      orElse: () => InterruptionPolicy.immediate,
    );
  }
}
