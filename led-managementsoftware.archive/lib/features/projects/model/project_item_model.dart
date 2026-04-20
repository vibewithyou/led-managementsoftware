import 'package:led_management_software/domain/entities/project.dart';

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

  int get configuredCueCount => cueAssignments.values.where((value) => value != null && value.trim().isNotEmpty).length;

  int get requiredCueCount => Project.requiredSlots.length;

  int get configuredSpecialClipCount => ProjectCueSlot.values
      .where((slot) => !slot.isCoreClip)
      .where((slot) {
        final value = cueAssignments[slot];
        return value != null && value.trim().isNotEmpty;
      })
      .length;

  String? cueIdForSlot(ProjectCueSlot slot) => cueAssignments[slot];

  ProjectItemModel withSlot(ProjectCueSlot slot, String? cueId) {
    final normalized = (cueId?.trim().isEmpty ?? true) ? null : cueId!.trim();
    return ProjectItemModel(
      id: id,
      name: name,
      opponent: opponent,
      venue: venue,
      date: date,
      clipCount: clipCount,
      isActive: isActive,
      fallbackCueId: slot == ProjectCueSlot.fallback ? normalized : fallbackCueId,
      sponsorLoopCueId: slot == ProjectCueSlot.sponsorLoop ? normalized : sponsorLoopCueId,
      introCueId: slot == ProjectCueSlot.intro ? normalized : introCueId,
      goalCueId: slot == ProjectCueSlot.goal ? normalized : goalCueId,
      yellowCardCueId: slot == ProjectCueSlot.yellowCard ? normalized : yellowCardCueId,
      redCardCueId: slot == ProjectCueSlot.redCard ? normalized : redCardCueId,
      penaltyCueId: slot == ProjectCueSlot.penalty ? normalized : penaltyCueId,
      sevenMeterCueId: slot == ProjectCueSlot.sevenMeter ? normalized : sevenMeterCueId,
      timeoutHomeCueId: slot == ProjectCueSlot.timeoutHome ? normalized : timeoutHomeCueId,
      timeoutGuestCueId: slot == ProjectCueSlot.timeoutGuest ? normalized : timeoutGuestCueId,
      wiperCueId: slot == ProjectCueSlot.wiper ? normalized : wiperCueId,
      halftimeCueId: slot == ProjectCueSlot.halftime ? normalized : halftimeCueId,
      gameEndCueId: slot == ProjectCueSlot.gameEnd ? normalized : gameEndCueId,
      isConfigurationComplete: _computeComplete(
        fallback: slot == ProjectCueSlot.fallback ? normalized : fallbackCueId,
        sponsor: slot == ProjectCueSlot.sponsorLoop ? normalized : sponsorLoopCueId,
        intro: slot == ProjectCueSlot.intro ? normalized : introCueId,
        goal: slot == ProjectCueSlot.goal ? normalized : goalCueId,
        yellowCard: slot == ProjectCueSlot.yellowCard ? normalized : yellowCardCueId,
        redCard: slot == ProjectCueSlot.redCard ? normalized : redCardCueId,
        penalty: slot == ProjectCueSlot.penalty ? normalized : penaltyCueId,
        sevenMeter: slot == ProjectCueSlot.sevenMeter ? normalized : sevenMeterCueId,
        timeoutHome: slot == ProjectCueSlot.timeoutHome ? normalized : timeoutHomeCueId,
        timeoutGuest: slot == ProjectCueSlot.timeoutGuest ? normalized : timeoutGuestCueId,
        wiper: slot == ProjectCueSlot.wiper ? normalized : wiperCueId,
        halftime: slot == ProjectCueSlot.halftime ? normalized : halftimeCueId,
        gameEnd: slot == ProjectCueSlot.gameEnd ? normalized : gameEndCueId,
      ),
    );
  }

  static bool _computeComplete({
    required String? fallback,
    required String? sponsor,
    required String? intro,
    required String? goal,
    required String? yellowCard,
    required String? redCard,
    required String? penalty,
    required String? sevenMeter,
    required String? timeoutHome,
    required String? timeoutGuest,
    required String? wiper,
    required String? halftime,
    required String? gameEnd,
  }) {
    final assignments = <ProjectCueSlot, String?>{
      ProjectCueSlot.fallback: fallback,
      ProjectCueSlot.sponsorLoop: sponsor,
      ProjectCueSlot.intro: intro,
      ProjectCueSlot.goal: goal,
      ProjectCueSlot.yellowCard: yellowCard,
      ProjectCueSlot.redCard: redCard,
      ProjectCueSlot.penalty: penalty,
      ProjectCueSlot.sevenMeter: sevenMeter,
      ProjectCueSlot.timeoutHome: timeoutHome,
      ProjectCueSlot.timeoutGuest: timeoutGuest,
      ProjectCueSlot.wiper: wiper,
      ProjectCueSlot.halftime: halftime,
      ProjectCueSlot.gameEnd: gameEnd,
    };

    return Project.requiredSlots.every((slot) {
      final value = assignments[slot];
      return value != null && value.trim().isNotEmpty;
    });
  }
}
