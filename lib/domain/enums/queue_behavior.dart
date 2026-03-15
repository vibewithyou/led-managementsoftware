enum QueueBehavior {
  enqueue,
  replace,
  ignore,
  forceFront,
}

extension QueueBehaviorX on QueueBehavior {
  String get value => name;

  static QueueBehavior fromValue(String? value) {
    return QueueBehavior.values.firstWhere(
      (item) => item.name == value,
      orElse: () => QueueBehavior.enqueue,
    );
  }
}
