import 'dart:collection';

import 'package:led_managementsoftware_app/domain/entities/quick_action.dart';
import 'package:led_managementsoftware_app/domain/enums/quick_action_type.dart';
import 'package:led_managementsoftware_app/domain/enums/team_side.dart';

class LiveActionCatalog {
  LiveActionCatalog._();

  static final UnmodifiableMapView<String, LiveActionRule> _rules = UnmodifiableMapView(
    {
      'Vor dem Spiel': _rule(
        action: const QuickAction(
          id: 'qa-pre',
          name: 'Vor dem Spiel',
          type: QuickActionType.preGame,
          targetSide: TeamSide.home,
          linkedSceneId: 'scene-pre',
          startsImmediately: true,
          canInterruptProtectedClip: false,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-pre',
      ),
      'Spielbeginn': _rule(
        action: const QuickAction(
          id: 'qa-kickoff',
          name: 'Spielbeginn',
          type: QuickActionType.kickoff,
          targetSide: TeamSide.away,
          linkedSceneId: 'scene-live',
          startsImmediately: true,
          canInterruptProtectedClip: false,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-live',
      ),
      'Pause': _rule(
        action: const QuickAction(
          id: 'qa-break',
          name: 'Pause',
          type: QuickActionType.breakPhase,
          targetSide: TeamSide.home,
          linkedSceneId: 'scene-break',
          startsImmediately: true,
          canInterruptProtectedClip: true,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-break',
      ),
      'Nach dem Spiel': _rule(
        action: const QuickAction(
          id: 'qa-post',
          name: 'Nach dem Spiel',
          type: QuickActionType.postGame,
          targetSide: TeamSide.away,
          linkedSceneId: 'scene-post',
          startsImmediately: false,
          canInterruptProtectedClip: false,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-post',
      ),
      'Einlauf Heim': _rule(
        action: const QuickAction(
          id: 'qa-intro-home',
          name: 'Einlauf Heim',
          type: QuickActionType.intro,
          targetSide: TeamSide.home,
          linkedSceneId: 'scene-intro-home',
          startsImmediately: true,
          canInterruptProtectedClip: false,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-intro-home',
      ),
      'Einlauf Gegner': _rule(
        action: const QuickAction(
          id: 'qa-intro-away',
          name: 'Einlauf Gegner',
          type: QuickActionType.intro,
          targetSide: TeamSide.away,
          linkedSceneId: 'scene-intro-away',
          startsImmediately: true,
          canInterruptProtectedClip: false,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-intro-away',
      ),
      '2 Minuten Heim': _rule(
        action: const QuickAction(
          id: 'qa-penalty-home',
          name: '2 Minuten Heim',
          type: QuickActionType.twoMinute,
          targetSide: TeamSide.home,
          linkedSceneId: 'scene-special-home',
          startsImmediately: true,
          canInterruptProtectedClip: true,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-special-home',
      ),
      '2 Minuten Gegner': _rule(
        action: const QuickAction(
          id: 'qa-penalty-away',
          name: '2 Minuten Gegner',
          type: QuickActionType.twoMinute,
          targetSide: TeamSide.away,
          linkedSceneId: 'scene-special-away',
          startsImmediately: true,
          canInterruptProtectedClip: true,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-special-away',
      ),
      'Timeout Heim': _rule(
        action: const QuickAction(
          id: 'qa-timeout-home',
          name: 'Timeout Heim',
          type: QuickActionType.timeout,
          targetSide: TeamSide.home,
          linkedSceneId: 'scene-timeout-home',
          startsImmediately: true,
          canInterruptProtectedClip: true,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-timeout-home',
      ),
      'Timeout Gegner': _rule(
        action: const QuickAction(
          id: 'qa-timeout-away',
          name: 'Timeout Gegner',
          type: QuickActionType.timeout,
          targetSide: TeamSide.away,
          linkedSceneId: 'scene-timeout-away',
          startsImmediately: true,
          canInterruptProtectedClip: true,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-timeout-away',
      ),
      'rote Karte': _rule(
        action: const QuickAction(
          id: 'qa-red-card',
          name: 'rote Karte',
          type: QuickActionType.redCard,
          targetSide: TeamSide.home,
          linkedSceneId: 'scene-card',
          startsImmediately: true,
          canInterruptProtectedClip: true,
          requiresConfirmation: true,
          isEnabled: true,
        ),
        sceneId: 'scene-card',
      ),
      'Wischer': _rule(
        action: const QuickAction(
          id: 'qa-wiper',
          name: 'Wischer',
          type: QuickActionType.wiper,
          targetSide: TeamSide.home,
          linkedSceneId: 'scene-wiper',
          startsImmediately: false,
          canInterruptProtectedClip: false,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-wiper',
      ),
      'Tor Heim': _rule(
        action: const QuickAction(
          id: 'qa-goal-home',
          name: 'Tor Heim',
          type: QuickActionType.homeGoal,
          targetSide: TeamSide.home,
          linkedSceneId: 'scene-goal-home',
          startsImmediately: true,
          canInterruptProtectedClip: false,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-goal-home',
      ),
      'Tor Gegner': _rule(
        action: const QuickAction(
          id: 'qa-goal-away',
          name: 'Tor Gegner',
          type: QuickActionType.awayGoal,
          targetSide: TeamSide.away,
          linkedSceneId: 'scene-goal-away',
          startsImmediately: true,
          canInterruptProtectedClip: false,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-goal-away',
      ),
      'Verletzung Heim': _rule(
        action: const QuickAction(
          id: 'qa-injury-home',
          name: 'Verletzung Heim',
          type: QuickActionType.injury,
          targetSide: TeamSide.home,
          linkedSceneId: 'scene-injury-home',
          startsImmediately: true,
          canInterruptProtectedClip: true,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-injury-home',
      ),
      'Verletzung Gegner': _rule(
        action: const QuickAction(
          id: 'qa-injury-away',
          name: 'Verletzung Gegner',
          type: QuickActionType.injury,
          targetSide: TeamSide.away,
          linkedSceneId: 'scene-injury-away',
          startsImmediately: true,
          canInterruptProtectedClip: true,
          requiresConfirmation: false,
          isEnabled: true,
        ),
        sceneId: 'scene-injury-away',
      ),
    },
  );

  static const List<String> homeColumnLabels = [
    'Vor dem Spiel',
    'Einlauf Heim',
    '2 Minuten Heim',
    'Timeout Heim',
    'Tor Heim',
    'Verletzung Heim',
    'Wischer',
  ];

  static const List<String> awayColumnLabels = [
    'Spielbeginn',
    'Einlauf Gegner',
    '2 Minuten Gegner',
    'Timeout Gegner',
    'Tor Gegner',
    'Verletzung Gegner',
    'rote Karte',
  ];

  static LiveActionRule? resolve(String actionName) => _rules[actionName];

  static LiveActionRule _rule({
    required QuickAction action,
    required String sceneId,
  }) {
    return (action: action, sceneId: sceneId);
  }
}

typedef LiveActionRule = ({QuickAction action, String sceneId});