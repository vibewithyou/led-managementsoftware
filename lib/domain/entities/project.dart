class Project {
  const Project({
    required this.id,
    required this.name,
    required this.opponent,
    required this.venue,
    required this.date,
    required this.fallbackCueId,
    required this.sponsorLoopCueId,
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
      clipCount: json['clipCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      isActive: json['isActive'] as bool? ?? false,
      isConfigurationComplete: json['isConfigurationComplete'] as bool? ?? _computeConfigurationComplete(
        (json['fallbackCueId'] ?? json['selectedFallbackCueId']) as String?,
        (json['sponsorLoopCueId'] ?? json['selectedSponsorLoopCueId']) as String?,
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
  final int clipCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isConfigurationComplete;

  Project copyWith({
    String? id,
    String? name,
    String? opponent,
    String? venue,
    DateTime? date,
    Object? fallbackCueId = _unset,
    Object? sponsorLoopCueId = _unset,
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
            clipCount == other.clipCount &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt &&
            isActive == other.isActive &&
            isConfigurationComplete == other.isConfigurationComplete;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      opponent,
      venue,
      date,
      fallbackCueId,
      sponsorLoopCueId,
      clipCount,
      createdAt,
      updatedAt,
      isActive,
      isConfigurationComplete,
    );
  }
}

const _unset = Object();


bool _computeConfigurationComplete(String? fallbackCueId, String? sponsorLoopCueId) {
  return fallbackCueId != null && fallbackCueId.isNotEmpty && sponsorLoopCueId != null && sponsorLoopCueId.isNotEmpty;
}
