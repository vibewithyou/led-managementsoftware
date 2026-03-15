class LiveCueModel {
  const LiveCueModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.remainingMs,
    required this.queuedAt,
  });

  final String id;
  final String title;
  final String category;
  final String status;
  final int remainingMs;
  final DateTime queuedAt;
}
