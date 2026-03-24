class ProjectItemModel {
  const ProjectItemModel({
    required this.id,
    required this.name,
    required this.opponent,
    required this.venue,
    required this.date,
    required this.clipCount,
    required this.isActive,
    required this.fallbackCueId,
    required this.sponsorLoopCueId,
    required this.isConfigurationComplete,
  });

  final String id;
  final String name;
  final String opponent;
  final String venue;
  final DateTime date;
  final int clipCount;
  final bool isActive;
  final String? fallbackCueId;
  final String? sponsorLoopCueId;
  final bool isConfigurationComplete;
}
