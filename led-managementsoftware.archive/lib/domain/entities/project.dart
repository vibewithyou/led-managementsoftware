enum ProjectCueSlot {
  sponsorLoop('Sponsor Loop', isCoreClip: true),
  fallback('Fallback', isCoreClip: true),
  intro('Einlauf/Intro'),
  goal('Tor'),
  yellowCard('Gelbe Karte'),
  redCard('Rote Karte'),
  penalty('2 Minuten'),
  sevenMeter('7 Meter'),
  timeoutHome('Timeout Heim'),
  timeoutGuest('Timeout Gast'),
  wiper('Wischer'),
  halftime('Halbzeit'),
  gameEnd('Spielende');

  const ProjectCueSlot(this.label, {this.isCoreClip = false});

  final String label;
  final bool isCoreClip;
}

class Project {
  const Project({
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
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.isConfigurationComplete,
  });

  factory Project.empty() {
    final now = DateTime.now();
    return Project(
      id: '',
      name: '',
      opponent: '',
      venue: '',
      date: now,
      fallbackCueId: null,
      sponsorLoopCueId: null,
      introCueId: null,
      goalCueId: null,
      yellowCardCueId: null,
      redCardCueId: null,
      penaltyCueId: null,
      sevenMeterCueId: null,
      timeoutHomeCueId: null,
      timeoutGuestCueId: null,
      wiperCueId: null,
      halftimeCueId: null,
      gameEndCueId: null,
      clipCount: 0,
      createdAt: now,
      updatedAt: now,
      isActive: false,
      isConfigurationComplete: false,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      opponent: json['opponent'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      fallbackCueId: (json['fallbackCueId'] ?? json['selectedFallbackCueId']) as String?,
      sponsorLoopCueId: (json['sponsorLoopCueId'] ?? json['selectedSponsorLoopCueId']) as String?,
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
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      isActive: json['isActive'] as bool? ?? false,
      isConfigurationComplete: json['isConfigurationComplete'] as bool? ?? _computeConfigurationComplete(
        fallbackCueId: (json['fallbackCueId'] ?? json['selectedFallbackCueId']) as String?,
        sponsorLoopCueId: (json['sponsorLoopCueId'] ?? json['selectedSponsorLoopCueId']) as String?,
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
      ),
    );
  }

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
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isConfigurationComplete;

  Map<ProjectCueSlot, String?> get cueAssignments => {
        ProjectCueSlot.sponsorLoop: sponsorLoopCueId,
        ProjectCueSlot.fallback: fallbackCueId,
      ProjectCueSlot.intro: introCueId,
        ProjectCueSlot.goal: goalCueId,
        ProjectCueSlot.yellowCard: yellowCardCueId,
        ProjectCueSlot.redCard: redCardCueId,
        ProjectCueSlot.penalty: penaltyCueId,
      ProjectCueSlot.sevenMeter: sevenMeterCueId,
        ProjectCueSlot.timeoutHome: timeoutHomeCueId,
        ProjectCueSlot.timeoutGuest: timeoutGuestCueId,
        ProjectCueSlot.wiper: wiperCueId,
        ProjectCueSlot.halftime: halftimeCueId,
        ProjectCueSlot.gameEnd: gameEndCueId,
      };

  int get configuredCueCount => cueAssignments.values.where(_hasCueValue).length;

  int get requiredCueCount => requiredSlots.length;

  static const Set<ProjectCueSlot> optionalSlots = {
    ProjectCueSlot.intro,
  };

  static final List<ProjectCueSlot> requiredSlots = ProjectCueSlot.values
      .where((slot) => !optionalSlots.contains(slot))
      .toList(growable: false);

  int get configuredSpecialClipCount => ProjectCueSlot.values
      .where((slot) => !slot.isCoreClip)
      .where((slot) => _hasCueValue(cueIdForSlot(slot)))
      .length;

  String? cueIdForSlot(ProjectCueSlot slot) {
    return cueAssignments[slot];
  }

  Project copyWith({
    String? id,
    String? name,
    String? opponent,
    String? venue,
    DateTime? date,
    Object? fallbackCueId = _unset,
    Object? sponsorLoopCueId = _unset,
    Object? introCueId = _unset,
    Object? goalCueId = _unset,
    Object? yellowCardCueId = _unset,
    Object? redCardCueId = _unset,
    Object? penaltyCueId = _unset,
    Object? sevenMeterCueId = _unset,
    Object? timeoutHomeCueId = _unset,
    Object? timeoutGuestCueId = _unset,
    Object? wiperCueId = _unset,
    Object? halftimeCueId = _unset,
    Object? gameEndCueId = _unset,
    int? clipCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isConfigurationComplete,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      opponent: opponent ?? this.opponent,
      venue: venue ?? this.venue,
      date: date ?? this.date,
      fallbackCueId: fallbackCueId == _unset ? this.fallbackCueId : fallbackCueId as String?,
      sponsorLoopCueId: sponsorLoopCueId == _unset ? this.sponsorLoopCueId : sponsorLoopCueId as String?,
      introCueId: introCueId == _unset ? this.introCueId : introCueId as String?,
      goalCueId: goalCueId == _unset ? this.goalCueId : goalCueId as String?,
      yellowCardCueId: yellowCardCueId == _unset ? this.yellowCardCueId : yellowCardCueId as String?,
      redCardCueId: redCardCueId == _unset ? this.redCardCueId : redCardCueId as String?,
      penaltyCueId: penaltyCueId == _unset ? this.penaltyCueId : penaltyCueId as String?,
      sevenMeterCueId: sevenMeterCueId == _unset ? this.sevenMeterCueId : sevenMeterCueId as String?,
      timeoutHomeCueId: timeoutHomeCueId == _unset ? this.timeoutHomeCueId : timeoutHomeCueId as String?,
      timeoutGuestCueId: timeoutGuestCueId == _unset ? this.timeoutGuestCueId : timeoutGuestCueId as String?,
      wiperCueId: wiperCueId == _unset ? this.wiperCueId : wiperCueId as String?,
      halftimeCueId: halftimeCueId == _unset ? this.halftimeCueId : halftimeCueId as String?,
      gameEndCueId: gameEndCueId == _unset ? this.gameEndCueId : gameEndCueId as String?,
      clipCount: clipCount ?? this.clipCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isConfigurationComplete: isConfigurationComplete ?? this.isConfigurationComplete,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'isConfigurationComplete': isConfigurationComplete,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Project &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            name == other.name &&
            opponent == other.opponent &&
            venue == other.venue &&
            date == other.date &&
            fallbackCueId == other.fallbackCueId &&
            sponsorLoopCueId == other.sponsorLoopCueId &&
            introCueId == other.introCueId &&
            goalCueId == other.goalCueId &&
            yellowCardCueId == other.yellowCardCueId &&
            redCardCueId == other.redCardCueId &&
            penaltyCueId == other.penaltyCueId &&
            sevenMeterCueId == other.sevenMeterCueId &&
            timeoutHomeCueId == other.timeoutHomeCueId &&
            timeoutGuestCueId == other.timeoutGuestCueId &&
            wiperCueId == other.wiperCueId &&
            halftimeCueId == other.halftimeCueId &&
            gameEndCueId == other.gameEndCueId &&
            clipCount == other.clipCount &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt &&
            isActive == other.isActive &&
            isConfigurationComplete == other.isConfigurationComplete;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      name,
      opponent,
      venue,
      date,
      fallbackCueId,
      sponsorLoopCueId,
      introCueId,
      goalCueId,
      yellowCardCueId,
      redCardCueId,
      penaltyCueId,
      sevenMeterCueId,
      timeoutHomeCueId,
      timeoutGuestCueId,
      wiperCueId,
      halftimeCueId,
      gameEndCueId,
      clipCount,
      createdAt,
      updatedAt,
      isActive,
      isConfigurationComplete,
    ]);
  }
}

const _unset = Object();


bool _computeConfigurationComplete({
  required String? fallbackCueId,
  required String? sponsorLoopCueId,
  required String? introCueId,
  required String? goalCueId,
  required String? yellowCardCueId,
  required String? redCardCueId,
  required String? penaltyCueId,
  required String? sevenMeterCueId,
  required String? timeoutHomeCueId,
  required String? timeoutGuestCueId,
  required String? wiperCueId,
  required String? halftimeCueId,
  required String? gameEndCueId,
}) {
  final assignments = <ProjectCueSlot, String?>{
    ProjectCueSlot.sponsorLoop: sponsorLoopCueId,
    ProjectCueSlot.fallback: fallbackCueId,
    ProjectCueSlot.intro: introCueId,
    ProjectCueSlot.goal: goalCueId,
    ProjectCueSlot.yellowCard: yellowCardCueId,
    ProjectCueSlot.redCard: redCardCueId,
    ProjectCueSlot.penalty: penaltyCueId,
    ProjectCueSlot.sevenMeter: sevenMeterCueId,
    ProjectCueSlot.timeoutHome: timeoutHomeCueId,
    ProjectCueSlot.timeoutGuest: timeoutGuestCueId,
    ProjectCueSlot.wiper: wiperCueId,
    ProjectCueSlot.halftime: halftimeCueId,
    ProjectCueSlot.gameEnd: gameEndCueId,
  };
  return Project.requiredSlots.every((slot) => _hasCueValue(assignments[slot]));
}

bool _hasCueValue(String? value) {
  return value != null && value.trim().isNotEmpty;
}
