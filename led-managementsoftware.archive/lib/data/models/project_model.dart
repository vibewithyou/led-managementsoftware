import 'package:led_management_software/domain/entities/project.dart';

class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.opponent,
    required this.venue,
    required this.date,
    required this.fallbackCueId,
    required this.sponsorLoopCueId,
    required this.introCueId,
    required this.goalCueId,
    required this.yellowCardCueId,
    required this.redCardCueId,
    required this.penaltyCueId,
    required this.sevenMeterCueId,
    required this.timeoutHomeCueId,
    required this.timeoutGuestCueId,
    required this.wiperCueId,
    required this.halftimeCueId,
    required this.gameEndCueId,
    required this.clipCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.isConfigurationComplete,
  });

  final String id;
  final String name;
  final String opponent;
  final String venue;
  final DateTime date;
  final String? fallbackCueId;
  final String? sponsorLoopCueId;
  final String? introCueId;
  final String? goalCueId;
  final String? yellowCardCueId;
  final String? redCardCueId;
  final String? penaltyCueId;
  final String? sevenMeterCueId;
  final String? timeoutHomeCueId;
  final String? timeoutGuestCueId;
  final String? wiperCueId;
  final String? halftimeCueId;
  final String? gameEndCueId;
  final int clipCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isConfigurationComplete;

  factory ProjectModel.fromEntity(Project entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      opponent: entity.opponent,
      venue: entity.venue,
      date: entity.date,
      fallbackCueId: entity.fallbackCueId,
      sponsorLoopCueId: entity.sponsorLoopCueId,
      introCueId: entity.introCueId,
      goalCueId: entity.goalCueId,
      yellowCardCueId: entity.yellowCardCueId,
      redCardCueId: entity.redCardCueId,
      penaltyCueId: entity.penaltyCueId,
      sevenMeterCueId: entity.sevenMeterCueId,
      timeoutHomeCueId: entity.timeoutHomeCueId,
      timeoutGuestCueId: entity.timeoutGuestCueId,
      wiperCueId: entity.wiperCueId,
      halftimeCueId: entity.halftimeCueId,
      gameEndCueId: entity.gameEndCueId,
      clipCount: entity.clipCount,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isConfigurationComplete: entity.isConfigurationComplete,
    );
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      opponent: json['opponent'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      fallbackCueId: json['fallbackCueId'] as String?,
      sponsorLoopCueId: json['sponsorLoopCueId'] as String?,
      introCueId: json['introCueId'] as String?,
      goalCueId: json['goalCueId'] as String?,
      yellowCardCueId: json['yellowCardCueId'] as String?,
      redCardCueId: json['redCardCueId'] as String?,
      penaltyCueId: json['penaltyCueId'] as String?,
      sevenMeterCueId: json['sevenMeterCueId'] as String?,
      timeoutHomeCueId: json['timeoutHomeCueId'] as String?,
      timeoutGuestCueId: json['timeoutGuestCueId'] as String?,
      wiperCueId: json['wiperCueId'] as String?,
      halftimeCueId: json['halftimeCueId'] as String?,
      gameEndCueId: json['gameEndCueId'] as String?,
      clipCount: json['clipCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      isConfigurationComplete: json['isConfigurationComplete'] as bool? ?? false,
    );
  }

  Project toEntity() {
    return Project(
      id: id,
      name: name,
      opponent: opponent,
      venue: venue,
      date: date,
      fallbackCueId: fallbackCueId,
      sponsorLoopCueId: sponsorLoopCueId,
      introCueId: introCueId,
      goalCueId: goalCueId,
      yellowCardCueId: yellowCardCueId,
      redCardCueId: redCardCueId,
      penaltyCueId: penaltyCueId,
      sevenMeterCueId: sevenMeterCueId,
      timeoutHomeCueId: timeoutHomeCueId,
      timeoutGuestCueId: timeoutGuestCueId,
      wiperCueId: wiperCueId,
      halftimeCueId: halftimeCueId,
      gameEndCueId: gameEndCueId,
      clipCount: clipCount,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isConfigurationComplete: isConfigurationComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'opponent': opponent,
      'venue': venue,
      'date': date.toIso8601String(),
      'fallbackCueId': fallbackCueId,
      'sponsorLoopCueId': sponsorLoopCueId,
      'introCueId': introCueId,
      'goalCueId': goalCueId,
      'yellowCardCueId': yellowCardCueId,
      'redCardCueId': redCardCueId,
      'penaltyCueId': penaltyCueId,
      'sevenMeterCueId': sevenMeterCueId,
      'timeoutHomeCueId': timeoutHomeCueId,
      'timeoutGuestCueId': timeoutGuestCueId,
      'wiperCueId': wiperCueId,
      'halftimeCueId': halftimeCueId,
      'gameEndCueId': gameEndCueId,
      'clipCount': clipCount,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isConfigurationComplete': isConfigurationComplete,
    };
  }
}
